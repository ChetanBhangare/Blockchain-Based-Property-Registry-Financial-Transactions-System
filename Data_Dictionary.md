# Data Dictionary for Web3 Property Management DApp

This document provides a detailed description of the key data elements and structures used in the Property Management system. Use this as a reference for what data to enter or expect when interacting with the DApp.

---

## 1. Smart Contract Data Structures

### A. Property Structure

| **Field**              | **Data Type**               | **Description**                                                                                     | **Example**                          |
|------------------------|-----------------------------|-----------------------------------------------------------------------------------------------------|--------------------------------------|
| `propertyAddress`      | `string`                    | The street address of the property.                                                                 | `"123 Main Street"`                  |
| `location`             | `string`                    | The general area or neighborhood.                                                                   | `"Downtown"`                         |
| `floors`               | `uint256`                   | Number of floors (set to 0 for land, 1 or more for houses).                                          | `2`                                  |
| `price`                | `uint256`                   | The property price in wei (1 ETH = 1e18 wei).                                                       | `1000000000000000000` (1 ETH)          |
| `forSale`              | `bool`                      | Flag to indicate if the property is listed for sale.                                                | `false`                              |
| `approvers`            | `address[]`                 | List of addresses allowed to approve transfer requests.                                             | `["0xabc...", "0xdef..."]`            |
| `requiredApprovals`    | `uint256`                   | Minimum number of approvals required to execute a property transfer.                                | `2`                                  |
| `propertyType`         | `enum PropertyType`         | Type of property: `0` for Land, `1` for House.                                                      | `PropertyType.House`                 |
| `additionalDetails`    | `mapping(string => string)` | A mapping for extra metadata (e.g., dimensions, special features).                                  | `{"lotSize": "5000 sq ft"}`          |

### B. TransferRequest Structure

| **Field**      | **Data Type**                  | **Description**                                       | **Example**                     |
|----------------|--------------------------------|-------------------------------------------------------|---------------------------------|
| `tokenId`      | `uint256`                      | The NFT token ID associated with the property.        | `3`                             |
| `from`         | `address`                      | Address of the current owner initiating the transfer. | `"0xabc..."`                    |
| `to`           | `address`                      | Address of the intended recipient.                    | `"0xdef..."`                    |
| `approvalCount`| `uint256`                      | Number of approvals received so far.                  | `1`                             |
| `isActive`     | `bool`                         | Indicates whether the transfer request is active.     | `true`                          |
| `hasApproved`  | `mapping(address => bool)`     | Tracks which addresses have approved the request.     | `{ "0xabc...": true }`           |

---

## 2. Frontend Data Structures & Forms

### A. Registration Form Fields

| **Field**             | **Data Type** | **Purpose**                                                       | **Example Input**         |
|-----------------------|---------------|-------------------------------------------------------------------|---------------------------|
| `regPropertyAddress`  | String        | Address of the property being registered.                         | `"456 Elm Street"`        |
| `regLocation`         | String        | General location or neighborhood.                                 |`"Uptown"`                 |
| `regFloors`           | Number        | Number of floors (0 for land).                                    | `3`                       |
| `regPrice`            | Number        | Price in ETH.                                                     | `1.`                      |
| `regPropertyType`     | Number        | 0 for Land, 1 for House.                                          | `1`                       |
| `regRequiredApprovals`| Number        | Minimum number of approvals required for transfers.               | `2`                       |

### B. Listing Form Fields

| **Field**      | **Data Type** | **Purpose**                             | **Example Input**  |
|----------------|---------------|-----------------------------------------|--------------------|
| `listTokenId`  | Number        | Token ID of the property to list.       | `5`                |
| `listPrice`    | Number        | New sale price in ETH.                  | `2.0`              |

### C. Buying Form Fields

| **Field**    | **Data Type** | **Purpose**                            | **Example Input**  |
|--------------|---------------|----------------------------------------|--------------------|
| `buyTokenId` | Number        | Token ID of the property to purchase.   | `5`                |

### D. Transfer Request Form Fields

| **Field**     | **Data Type** | **Purpose**                                       | **Example Input**          |
|---------------|---------------|---------------------------------------------------|----------------------------|
| `tokenId`     | Number        | Token ID for which the transfer is requested.     | `5`                        |
| `recipient`   | String        | Ethereum address of the new owner.                | `"0xRecipientAddress..."`  |

### E. Approval Form Fields

| **Field**    | **Data Type** | **Purpose**                                | **Example Input**  |
|--------------|---------------|--------------------------------------------|--------------------|
| `requestId`  | Number        | ID of the transfer request to be approved. | `2`                |

---

## 3. Usage Instructions

- **Smart Contract Interaction:**  
  Use the data dictionary above as a reference when interacting with the smart contract. Ensure that the data types and expected formats match those outlined.

- **Frontend Forms:**  
  Use the examples provided in the dictionary for form inputs in your Vue views. For instance, when registering a property, ensure that the "Price" field receives a numeric value (e.g., `1.5` for 1.5 ETH) and "Property Type" is set appropriately (0 for Land or 1 for House).

- **Transfer Operations:**  
  When creating or approving a transfer request, use the corresponding fields as defined in the dictionary.

---

To download this file, simply save the above text as `Data_Dictionary.md` in your project folder. This file serves as a reference for developers and end users interacting with the DApp.

Let me know if you need any additional changes or further assistance!
