/// Blockchain-related constants
class BlockchainConstants {
  // Network Configuration - Polygon Mumbai Testnet
  static const String networkName = 'Polygon Mumbai';
  static const String rpcUrl = 'https://rpc-mumbai.maticvigil.com/';
  static const int chainId = 80001;
  static const String currencySymbol = 'MATIC';
  static const String explorerBaseUrl = 'https://mumbai.polygonscan.com';
  
  // Smart Contract (will be updated after deployment)
  static const String contractAddress = '0x0000000000000000000000000000000000000000'; // TODO: Update after deployment
  
  // Transaction Settings
  static const int transactionTimeoutSeconds = 60;
  static const int confirmationBlocks = 1;
  static const double minMaticBalance = 0.1;
  
  // Gas Settings
  static const int defaultGasLimit = 100000;
  
  // Faucet
  static const String faucetUrl = 'https://faucet.polygon.technology/';
  
  // Explorer URLs
  static String getTransactionUrl(String txHash) {
    return '$explorerBaseUrl/tx/$txHash';
  }
  
  static String getAddressUrl(String address) {
    return '$explorerBaseUrl/address/$address';
  }
  
  static String getBlockUrl(int blockNumber) {
    return '$explorerBaseUrl/block/$blockNumber';
  }
}
