// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

// Import OpenZeppelin libraries for ERC721, Access Control, and reentrancy protection.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Chainlink Price Feed interface
import "@openzeppelin/contracts/utils/Strings.sol"; // For converting uint256 to string

contract PropertyManagement is ERC721, AccessControl, ReentrancyGuard {
    // Define roles for Access Control.
    bytes32 public constant DEVELOPMENT_AUTHORITY = keccak256("DEVELOPMENT_AUTHORITY");
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant BUYER_SELLER_ROLE = keccak256("BUYER_SELLER_ROLE");

    enum PropertyType { Land, House }

    struct Property {
        string propertyAddress;
        string location;
        uint256 floors;
        uint256 price;
        bool forSale;
        address[] approvers;
        uint256 requiredApprovals;
        PropertyType propertyType;
        // additionalDetails mapping reserved for future use.
        mapping(string => string) additionalDetails;
    }

    struct TransferRequest {
        uint256 tokenId;
        address from;
        address to;
        uint256 approvalCount;
        bool isActive;
        mapping(address => bool) hasApproved;
    }

    uint256 private _tokenIds;
    uint256 private _transferRequestIds;

    // Mappings for properties and transfer requests.
    mapping(uint256 => Property) public properties;
    mapping(uint256 => TransferRequest) public transferRequests;

    // Chainlink Price Feed.
    AggregatorV3Interface public priceFeed;

    // Compliance flag and event.
    bool public complianceEnabled = true;
    event ComplianceEnabledSet(bool enabled);

    // Events for logging key actions.
    event PropertyRegistered(uint256 indexed tokenId, string propertyAddress, address owner);
    event PropertyAllotted(uint256 indexed tokenId, string propertyAddress, address verifiedOwner);
    event PropertyTransferred(uint256 indexed tokenId, address from, address to);
    event PropertyListedForSale(uint256 indexed tokenId, uint256 price);
    event PropertySold(uint256 indexed tokenId, address from, address to, uint256 price);
    event TransferRequestCreated(uint256 indexed requestId, uint256 indexed tokenId, address from, address to);
    event TransferRequestApproved(uint256 indexed requestId, address approver);
    event TransferRequestExecuted(uint256 indexed requestId);
    event PriceUpdated(uint256 tokenId, uint256 newPrice);

    constructor(address _priceFeed) ERC721("Property Management", "PROP") {
        // Grant roles to the deployer.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEVELOPMENT_AUTHORITY, msg.sender);
        _grantRole(APPROVER_ROLE, msg.sender);
        _grantRole(BUYER_SELLER_ROLE, msg.sender);

        // Set the Chainlink Price Feed.
        priceFeed = AggregatorV3Interface(_priceFeed);

        // Prepare initial approvers.
        address[] memory initialApprovers = new address[](1);
        initialApprovers[0] = msg.sender;

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        // Initialize a sample property.
        Property storage newProperty = properties[newTokenId];
        newProperty.propertyAddress = "123 Initial Property";
        newProperty.location = "Genesis Block";
        newProperty.floors = 2;
        newProperty.price = 1 ether;
        newProperty.forSale = false;
        newProperty.approvers = initialApprovers;
        newProperty.requiredApprovals = 1;
        newProperty.propertyType = PropertyType.House;

        _safeMint(msg.sender, newTokenId);
        // Enforce compliance check.
        require(checkCompliance(newTokenId), "Initial property does not meet compliance requirements");

        emit PropertyRegistered(newTokenId, newProperty.propertyAddress, msg.sender);
    }

    // Override supportsInterface because both ERC721 and AccessControl implement it.
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Getter function for property details.
    function getProperty(uint256 tokenId) public view returns (
        string memory propertyAddress,
        string memory location,
        uint256 floors,
        uint256 price,
        bool forSale,
        address[] memory approvers,
        uint256 requiredApprovals,
        uint8 propertyType
    ) {
        Property storage property = properties[tokenId];
        return (
            property.propertyAddress,
            property.location,
            property.floors,
            property.price,
            property.forSale,
            property.approvers,
            property.requiredApprovals,
            uint8(property.propertyType)
        );
    }

    // Helper: Check if an account is an approver for a property.
    function isApprover(uint256 tokenId, address account) public view returns (bool) {
        Property storage property = properties[tokenId];
        for (uint i = 0; i < property.approvers.length; i++) {
            if (property.approvers[i] == account) {
                return true;
            }
        }
        return false;
    }

    // Override grantRole to restrict it to DEVELOPMENT_AUTHORITY.
    function grantRole(bytes32 role, address account) public override onlyRole(DEVELOPMENT_AUTHORITY) {
        _grantRole(role, account);
    }

    // Toggle compliance checks (only Development Authority can call).
    function setComplianceEnabled(bool enabled) public onlyRole(DEVELOPMENT_AUTHORITY) {
        complianceEnabled = enabled;
        emit ComplianceEnabledSet(enabled);
    }

    // Register property (only Development Authority can call).
    function registerProperty(
        address verifiedOwner,
        string memory _propertyAddress,
        string memory _location,
        uint256 _floors,
        uint256 _price,
        PropertyType _propertyType,
        address[] memory _approvers,
        uint256 _requiredApprovals
    ) public onlyRole(DEVELOPMENT_AUTHORITY) returns (uint256) {
        require(_approvers.length >= _requiredApprovals, "Not enough approvers provided");

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        Property storage newProperty = properties[newTokenId];
        newProperty.propertyAddress = _propertyAddress;
        newProperty.location = _location;
        newProperty.floors = _floors;
        newProperty.price = _price;
        newProperty.forSale = false;
        newProperty.approvers = _approvers;
        newProperty.requiredApprovals = _requiredApprovals;
        newProperty.propertyType = _propertyType;

        _safeMint(verifiedOwner, newTokenId);
        grantRole(BUYER_SELLER_ROLE, verifiedOwner);

        if (complianceEnabled) {
            require(checkCompliance(newTokenId), "Property does not meet compliance requirements");
        }
        emit PropertyRegistered(newTokenId, _propertyAddress, verifiedOwner);
        emit PropertyAllotted(newTokenId, _propertyAddress, verifiedOwner);
        return newTokenId;
    }

    // Update property price using Chainlink Oracle (only Development Authority can call).
    function updatePropertyPrice(uint256 tokenId, uint256 newPrice) public onlyRole(DEVELOPMENT_AUTHORITY) {
        require(ownerOf(tokenId) != address(0), "Property does not exist");
        Property storage property = properties[tokenId];
        try priceFeed.latestRoundData() returns (uint80, int256 latestPrice, uint256, uint256, uint80) {
            require(latestPrice >= 0, "Negative price from price feed");
            uint256 oraclePrice = uint256(latestPrice) * 1e10; // Adjusting from 8 to 18 decimals.
            require(newPrice <= oraclePrice * 2, "Price exceeds market range");
            property.price = newPrice;
            emit PriceUpdated(tokenId, newPrice);
        } catch {
            revert("Failed to fetch price from price feed");
        }
    }

    // Create transfer request (only accounts with BUYER_SELLER_ROLE can call).
    function createTransferRequest(uint256 tokenId, address to) public onlyRole(BUYER_SELLER_ROLE) {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(to != address(0), "Invalid recipient address");

        _transferRequestIds++;
        uint256 requestId = _transferRequestIds;

        TransferRequest storage request = transferRequests[requestId];
        request.tokenId = tokenId;
        request.from = msg.sender;
        request.to = to;
        request.approvalCount = 0;
        request.isActive = true;

        emit TransferRequestCreated(requestId, tokenId, msg.sender, to);
    }

    // Approve transfer request (only accounts with APPROVER_ROLE can call).
    function approveTransfer(uint256 requestId) public onlyRole(APPROVER_ROLE) {
        TransferRequest storage request = transferRequests[requestId];
        Property storage property = properties[request.tokenId];

        require(request.isActive, "Transfer request is not active");
        require(!request.hasApproved[msg.sender], "Already approved");
        require(isApprover(request.tokenId, msg.sender), "Not an approver");

        request.hasApproved[msg.sender] = true;
        request.approvalCount++;

        emit TransferRequestApproved(requestId, msg.sender);

        if (request.approvalCount >= property.requiredApprovals) {
            _executeTransfer(requestId);
        }
    }

    // Internal function to execute a transfer once approvals are met.
    function _executeTransfer(uint256 requestId) internal {
        TransferRequest storage request = transferRequests[requestId];
        require(request.isActive, "Transfer request is not active");
        request.isActive = false;
        address from = request.from;
        address to = request.to;
        uint256 tokenId = request.tokenId;
        _transfer(from, to, tokenId);
        properties[tokenId].forSale = false;

        emit TransferRequestExecuted(requestId);
        emit PropertyTransferred(tokenId, from, to);
    }

    // Buy property (with reentrancy guard and compliance check).
    function buyProperty(uint256 tokenId) public payable nonReentrant {
        Property storage property = properties[tokenId];
        require(property.forSale, "Property not for sale");
        require(msg.value >= property.price, "Insufficient payment");
        require(checkCompliance(tokenId), "Property does not meet compliance requirements");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        property.forSale = false;
        payable(seller).transfer(msg.value);

        emit PropertySold(tokenId, seller, msg.sender, msg.value);
    }

    // Compliance check function: if compliance is disabled, always return true.
    function checkCompliance(uint256 tokenId) public view returns (bool) {
        if (!complianceEnabled) {
            return true;
        }
        Property storage property = properties[tokenId];
        require(bytes(property.propertyAddress).length > 0, "Property not found");
        
        try priceFeed.latestRoundData() returns (uint80, int256 complianceData, uint256, uint256, uint80) {
            return complianceData > 0;
        } catch {
            return false; // Instead of reverting, return false to allow testing
        }
    }


    // List property for sale (only owners can call).
    function listPropertyForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        properties[tokenId].forSale = true;
        properties[tokenId].price = price;
        emit PropertyListedForSale(tokenId, price);
    }

    // Withdraw funds from the contract (only Development Authority can call).
    function withdrawFunds() public onlyRole(DEVELOPMENT_AUTHORITY) {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Fallback function to receive Ether.
    receive() external payable {}
}
