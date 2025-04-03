// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VmNonceTest is Test {
    address public player = vm.addr(666666);

    function setUp() external {}

    function testNonce() public {
        //! this will satisfy when we run with --isolate flag
        vm.startPrank(player, player);
        ERC20Mock token = new ERC20Mock();
        token.transfer(address(2), 0);
        assertEq(2, vm.getNonce(player));
        vm.stopPrank();
    }

    function testNonce_2() public {
        vm.startPrank(player, player);
        new ERC20Mock();
        new ERC20Mock();
        assertEq(2, vm.getNonce(player));
        vm.stopPrank();
    }
}
