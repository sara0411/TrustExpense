// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ReceiptCertifier
 * @dev Smart contract for certifying receipt authenticity on Polygon Mumbai
 * 
 * This contract provides an immutable record of receipt hashes, proving that
 * a receipt existed at a specific timestamp and has not been tampered with.
 * 
 * Features:
 * - Store receipt certificate hashes on-chain
 * - Timestamp-based proof of existence
 * - Verification of certificate authenticity
 * - Event emission for off-chain indexing
 */
contract ReceiptCertifier {
    
    // Structure to store certificate data
    struct Certificate {
        bytes32 receiptHash;      // SHA-256 hash of receipt data
        address certifier;        // Address that certified the receipt
        uint256 timestamp;        // Block timestamp when certified
        bool exists;              // Flag to check if certificate exists
    }
    
    // Mapping from certificate ID to Certificate struct
    mapping(bytes32 => Certificate) public certificates;
    
    // Mapping to track certificates by user address
    mapping(address => bytes32[]) public userCertificates;
    
    // Counter for total certificates issued
    uint256 public totalCertificates;
    
    // Events
    event ReceiptCertified(
        bytes32 indexed certificateId,
        bytes32 indexed receiptHash,
        address indexed certifier,
        uint256 timestamp
    );
    
    event CertificateVerified(
        bytes32 indexed certificateId,
        bool isValid
    );
    
    /**
     * @dev Certify a receipt by storing its hash on-chain
     * @param _receiptHash SHA-256 hash of the receipt data
     * @return certificateId Unique identifier for this certificate
     * 
     * NOTE: This function is intentionally public (no access control).
     * Any user can certify their own receipts. Each certificate is tied
     * to msg.sender, preventing impersonation. For enterprise use cases
     * requiring centralized control, add Ownable or role-based access.
     */
    function certifyReceipt(bytes32 _receiptHash) external returns (bytes32) {
        // Generate unique certificate ID from receipt hash and certifier address
        // Using abi.encode (not encodePacked) to prevent hash collision attacks
        bytes32 certificateId = keccak256(
            abi.encode(_receiptHash, msg.sender, block.timestamp)
        );
        
        // Ensure this certificate doesn't already exist
        require(!certificates[certificateId].exists, "Certificate already exists");
        
        // Create and store the certificate
        certificates[certificateId] = Certificate({
            receiptHash: _receiptHash,
            certifier: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });
        
        // Track certificate for this user
        userCertificates[msg.sender].push(certificateId);
        
        // Increment counter
        totalCertificates++;
        
        // Emit event
        emit ReceiptCertified(certificateId, _receiptHash, msg.sender, block.timestamp);
        
        return certificateId;
    }
    
    /**
     * @dev Verify if a certificate exists and is valid
     * @param _certificateId The certificate ID to verify
     * @return isValid True if certificate exists
     * @return receiptHash The receipt hash stored in the certificate
     * @return certifier Address that created the certificate
     * @return timestamp When the certificate was created
     */
    function verifyCertificate(bytes32 _certificateId) 
        external 
        view 
        returns (
            bool isValid,
            bytes32 receiptHash,
            address certifier,
            uint256 timestamp
        ) 
    {
        Certificate memory cert = certificates[_certificateId];
        
        return (
            cert.exists,
            cert.receiptHash,
            cert.certifier,
            cert.timestamp
        );
    }
    
    /**
     * @dev Get all certificate IDs for a specific user
     * @param _user Address of the user
     * @return Array of certificate IDs
     */
    function getUserCertificates(address _user) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return userCertificates[_user];
    }
    
    /**
     * @dev Check if a receipt hash has been certified
     * @param _receiptHash The receipt hash to check
     * @param _certifier The address of the certifier
     * @return exists True if a certificate exists for this hash and certifier
     */
    function isCertified(bytes32 _receiptHash, address _certifier) 
        external 
        view 
        returns (bool exists) 
    {
        bytes32[] memory userCerts = userCertificates[_certifier];
        
        for (uint i = 0; i < userCerts.length; i++) {
            if (certificates[userCerts[i]].receiptHash == _receiptHash) {
                return true;
            }
        }
        
        return false;
    }
}
