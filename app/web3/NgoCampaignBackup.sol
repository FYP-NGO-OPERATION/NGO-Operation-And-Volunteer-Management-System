// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NgoCampaignBackup
 * @dev Decentralized, censorship-resistant backup ledger for NGO Campaign Data.
 * This contract acts as an immutable registry for IPFS hashes pointing to
 * critical operational and financial data snapshots.
 */
contract NgoCampaignBackup {
    
    struct BackupRecord {
        string ipfsHash;
        uint256 timestamp;
        string dataSignature; // Post-quantum resistant verification signature
    }
    
    address public owner;
    
    // Mapping of Campaign ID to a list of its backup records
    mapping(string => BackupRecord[]) private campaignBackups;
    
    event BackupCommitted(string indexed campaignId, string ipfsHash, uint256 timestamp);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Web3/IPFS Fallback requires owner privileges");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Commits a new IPFS hash containing campaign data backup.
     * @param campaignId Unique identifier of the campaign.
     * @param ipfsHash IPFS CID of the encrypted JSON backup.
     * @param signature Cryptographic signature of the hash for zero-trust validation.
     */
    function commitBackup(
        string memory campaignId, 
        string memory ipfsHash, 
        string memory signature
    ) public onlyOwner {
        BackupRecord memory newBackup = BackupRecord({
            ipfsHash: ipfsHash,
            timestamp: block.timestamp,
            dataSignature: signature
        });
        
        campaignBackups[campaignId].push(newBackup);
        
        emit BackupCommitted(campaignId, ipfsHash, block.timestamp);
    }
    
    /**
     * @dev Retrieves the latest immutable IPFS backup hash for a campaign.
     * @param campaignId Unique identifier of the campaign.
     * @return ipfsHash IPFS CID of the latest backup.
     * @return timestamp When the backup was committed.
     * @return dataSignature The cryptographic signature for verification.
     */
    function getLatestBackup(string memory campaignId) 
        public 
        view 
        returns (string memory ipfsHash, uint256 timestamp, string memory dataSignature) 
    {
        uint256 length = campaignBackups[campaignId].length;
        require(length > 0, "No backups found for this campaign");
        
        BackupRecord memory latest = campaignBackups[campaignId][length - 1];
        return (latest.ipfsHash, latest.timestamp, latest.dataSignature);
    }
}
