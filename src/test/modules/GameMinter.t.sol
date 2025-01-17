// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../Hevm.sol';
import 'ds-test/test.sol';
import '../../ConnectFour.sol';
import '../../modules/GameMinter.sol';

contract User {}

contract GameMinterTest is DSTest {
	User internal user;
	Hevm internal hevm;
	GameMinter internal nft;
	ConnectFour internal game;

	constructor() {
		user = new User();
		game = new ConnectFour();
		hevm = Hevm(HEVM_ADDRESS);
		nft = new GameMinter(game);
	}

	function testCanMintFinishedGame() public {
		uint256 gameId = _getFinishedGame();
		assertEq(nft.ownerOf(gameId), address(0));

		nft.mint(gameId);

		assertEq(nft.ownerOf(gameId), address(this));
	}

	function testCannotMintUnfinishedGame() public {
		hevm.prank(address(user));
		uint256 gameId = game.challenge(address(this));
		assertEq(nft.ownerOf(gameId), address(0));

		hevm.expectRevert(GameMinter.CannotMintGame.selector);
		nft.mint(gameId);

		assertEq(nft.ownerOf(gameId), address(0));
	}

	function testLoserCannotMintFinishedGame() public {
		uint256 gameId = _getFinishedGame();
		assertEq(nft.ownerOf(gameId), address(0));

		hevm.prank(address(user));
		hevm.expectRevert(GameMinter.CannotMintGame.selector);
		nft.mint(gameId);

		assertEq(nft.ownerOf(gameId), address(0));
	}

	function _getFinishedGame() internal returns (uint256) {
		hevm.prank(address(user));
		uint256 gameId = game.challenge(address(this));

		game.makeMove(gameId, 4);
		hevm.prank(address(user));
		game.makeMove(gameId, 3);
		game.makeMove(gameId, 4);
		hevm.prank(address(user));
		game.makeMove(gameId, 3);
		game.makeMove(gameId, 4);
		hevm.prank(address(user));
		game.makeMove(gameId, 3);
		game.makeMove(gameId, 4);

		return gameId;
	}
}
