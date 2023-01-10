// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./LockToken.sol";
import "./IERC20.sol";

contract Agent {
    LockToken  lock_token=LockToken(0x1dC4c1cEFEF38a777b15aA20260a54E584b16C48);
    address deployer=address(0x5409ED021D9299bf6814279A6A1411A7e866A631);
    address thisAgent=address(0x00a329c0648769A73afAc7F9381E08FB43dBEA72);
    ////dependencies
    address v3Migrator=address(0xbe0037eAf2d64fe5529BCa93c18C9702D3930376);
    address v3nonfungiblePositionManager=address(0x1E2F9E10D02a6b8F8f69fcBf515e75039D2EA30d);
    address fakeToken=address(0x07f96Aa816C1F244CbC6ef114bB2b023Ba54a2EB);
    address weth=address(0x871DD7C2B4b25E1Aa18728e9D5f2Af4C4e431f5c);
    address v2Tokenpair=address(0x06f66Fbc3EBeCF0D3286bBE923e415af29344f09);
    
    uint256 id;

    constructor() public {
    }

    function callLockToken(
        uint256 _amount,
        uint256 _unlockTime,
        bool _mintNFT
    )
    external 
    payable
    {
        address _tokenAddress = fakeToken;
        address _withdrawalAddress = thisAgent;
        bool ret = IERC20(_tokenAddress).approve(address(lock_token), _amount);
	      assert(ret);
        assert(IERC20(_tokenAddress).allowance(thisAgent, address(lock_token)) == _amount);
        id = lock_token.lockToken{value: msg.value}(_tokenAddress, _withdrawalAddress, _amount, _unlockTime, _mintNFT);
    }

    function callMigrate(
	      IV3Migrator.MigrateParams calldata _params,
        bool noLiquidity,
        uint160 sqrtPriceX96,
        bool _mintNFT
    )
    external
    payable
    {
        IV3Migrator.MigrateParams memory params;           
	      params = _params;
	      params.pair = v2Tokenpair;
        if(fakeToken > weth)
        {
            params.token0 = weth;
	        params.token1 = fakeToken;
        } else
        {
            params.token0 = fakeToken;
	        params.token1 = weth;
        }
        params.recipient = thisAgent;
        params.fee = 500;
        //uint160 price = 79228162514264337593543950336;
        lock_token.migrate{value: msg.value}(id, params, true, sqrtPriceX96, _mintNFT);
    }
    function callLockNFT(
        address _tokenAddress,
        address _withdrawalAddress,
        uint256 _amount,
        uint256 _unlockTime,
        uint256 _tokenId,
        bool _mintNFT 
    )
    external
    payable
    {
        lock_token.lockNFT(_tokenAddress, _withdrawalAddress, _amount, _unlockTime, _tokenId, _mintNFT);
    }

    function callMintNFTforLock(uint256 _id)
    external
    {
        lock_token.mintNFTforLock(_id);
    }

    function callTransferOwnershipNFTContract(address _newOwner)
    external
    {
        lock_token.transferOwnershipNFTContract(_newOwner);
    }

    function callSetNotEntered()
    external
    {
        lock_token.setNotEntered();
    }

    function echidna_check_balance() public returns (bool){
        uint256 actual_amount = 0; 
        actual_amount = IERC20(weth).balanceOf(thisAgent);
        return(actual_amount == 0);
    }
}
