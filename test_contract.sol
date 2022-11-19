// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


// Amended by HashLips
/**
    !Disclaimer!

    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    The developer will not be responsible or liable for all loss or 
    damage whatsoever caused by you participating in any way in the 
    experimental code, whether putting money into the contract or 
    using the code for your own project.
*/

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
pragma solidity >=0.7.0 <0.9.0;

contract Dailys is
    ERC721Enumerable,
    VRFConsumerBase,
    KeeperCompatibleInterface,
    Ownable
{
    mapping(string => bool) private takenNames;
    mapping(uint256 => Attr) public attributes;

    struct Attr {
        string DayNumber;
        string name;
        uint256 edition;
        uint256 masterNumber;
        bool switchOn;
        uint256 switchPoint;
        bool svg_True_False;
        string SVG_Image;
        string imageA;
        string imageNameA;
        string imageB;
        string imageNameB;
    }
    // SUNSET parameters
    struct Ball {
        uint256 x; // x coordinates of the top left corner
        uint256 y; // y coordinates of the top left corner
        uint256 width;
        uint256 height;
        string fill; // ball color
        uint256 randomBase;
    }
    // Events
    event BallsCreated(uint256 indexed tokenId);

    using Strings for uint256;

    string public svgToImage;
    string public highImageURI;
    string public lowImageURI;
    string public ImageURI;
    string public auctionURI;
    string public auctionName;
    string public stagingName;
    string public gradient2_Stop1Builder;
    string public gradient2_Stop2Builder;
    address public ownerAddress = 0x2ba0C50eDd0899b0099344bE075DE642c9ee46fe;
    uint256 startingTime = block.timestamp;
    uint256 endTime;
    uint256 rand;
    uint256 public switchPoint = 5;
    uint256 public randomRange = 20;
    uint256 public imageRand;
    uint256 public durationRand1 = randMod(333);
    uint256 public durationRand2 = randMod(666);
    uint256 public durationRand3 = randMod(999);
    uint256 randNonce = 0;
    string public baseExtension = ".json";
    uint256 public cost = .00369 ether;
    uint256 public maxSupply = 2555;
    uint256 public maxMintAmount = 1;
    uint256 public maxDailyCopies = 7;
    bool public paused = false;
    bool public revealed = true;
    bool public switchOn = true;
    bool public svgOn = true;
    string public stagingURI;
    uint8 public count = 1;
    uint256 public baseCost = .00369 ether;
    uint256 public costMultiplier = uint256(100000000) / uint256(8784);
    uint256 public auctionDuration = 86200;

    //////////////////////////////
    // chainlink VRF
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    // chainlink keeper
    uint256 public counter;
    /**
     * Use an interval in seconds and a timestamp to slow execution of Upkeep
     */
    uint256 public interval;
    uint256 public lastTimeStamp;



    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initauctionURI,
        string memory _initauctionName,
        string memory _initstagingURI,
        string memory _initstagingName,
        uint256 updateInterval
    )
        VRFConsumerBase(
            0x3d2341ADb2D31f1c5530cDC622016af293177AE0, // VRF Coordinator
            0xb0897686c545045aFc77CF20eC7A532E3120E0F1 // LINK Token
        )
        ERC721(_name, _symbol)
    {
        setauctionURI(_initauctionURI, _initauctionName);
        setstagingURI(_initstagingURI, _initstagingName);
        keyHash = 0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;
        fee = 0.0001 * 10**18; // 0.1 LINK (Varies by network)
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }

    //VRF Chainlink stuff
    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;
    }

    //Chainlink Keeper stuff
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            counter = counter + 1;
            //            auctionName = stagingName;
            //            auctionURI = stagingURI;
            startingTime = block.timestamp;
            cost = baseCost;
            paused = false;
            imageRand = randMod(randomRange);
            if (count <= 1) {
                uint256 supply = totalSupply();
                uint256 tokenId = supply + 1;
                switchPoint = randMod(randomRange);
                durationRand1 = randMod(333);
                durationRand2 = randMod(666);
                durationRand3 = randMod(999);
                rand = randMod(33);
                attributes[tokenId] = Attr(
                    uint2str(counter),
                    buildName(tokenId),
                    count,
                    rand,
                    switchOn,
                    switchPoint,
                    svgOn,
                    svgToImageURI(getSvg()),
                    auctionURI,
                    auctionName,
                    stagingURI,
                    stagingName
                );
                _safeMint(ownerAddress, supply + 1);
            } else {
                count = 1;
            }
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function buildName(uint256 tokenId) public view returns (string memory) {
        string memory tempName = "Day #";
        string memory tempName2 = "  ";
        string memory tempName3 = attributes[tokenId].DayNumber;
        string memory imageName = attributes[tokenId].imageNameA;
        bool _switchOn = attributes[tokenId].switchOn;
        uint256 _switchPoint = attributes[tokenId].switchPoint;

        if (_switchOn == true) {
            if (imageRand >= _switchPoint) {
                imageName = attributes[tokenId].imageNameB;
            }
        }
        return
            string(abi.encodePacked(tempName, tempName3, tempName2, imageName));
    }

    // internal view
    function _auctionURI()
        internal
        view
        virtual
//        override
        returns (string memory)
    {
        return auctionURI;
    }

    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender,
                        randNonce
                    )
                )
            ) % _modulus;
    }

    //external view
    function randModulus(uint256 mod) external view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % mod;
    }

    function remainingTime(uint256) external view returns (uint256) {
        return uint256((startingTime + auctionDuration) - block.timestamp);
    }

    // public
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        uint256 tokenId = supply + _mintAmount;
        imageRand = randMod(randomRange);
        switchPoint = randMod(randomRange);
        durationRand1 = randMod(333);
        durationRand2 = randMod(666);
        durationRand3 = randMod(999);
        rand = randMod(33);
        attributes[tokenId] = Attr(
            uint2str(counter),
            buildName(tokenId),
            count,
            rand,
            switchOn,
            switchPoint,
            svgOn,
            svgToImageURI(getSvg()),
            auctionURI,
            auctionName,
            stagingURI,
            stagingName
        );
        attributes[tokenId] = Attr(
            uint2str(counter),
            buildName(tokenId),
            count,
            rand,
            switchOn,
            switchPoint,
            svgOn,
            svgToImageURI(getSvg()),
            auctionURI,
            auctionName,
            stagingURI,
            stagingName
        );

        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount);
        }

        if (block.timestamp >= startingTime + auctionDuration) {
            cost = baseCost;
            count = 1;
            paused = true;
        } else {
            _safeMint(msg.sender, supply + 1);
            cost = (cost * costMultiplier) / 10000000000000000;
            cost = cost * 1000000000000;
            count = count + 1;

            if (totalSupply() % maxDailyCopies == 0) {
                paused = true;
                cost = baseCost;
                count = 1;
            }
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        str = string(bstr);
    }

    //////////////////////BUILD SUNSETS////////////////////////////

    function backgroundColors(uint256 index)
        internal
        pure
        returns (string memory)
    {
        string[12] memory bgColors = [
            "red",
            "red",
            "purple",
            "blue",
            "green",
            "gold",
            "silver",
            "yellow",
            "yellow",
            "orange",
            "orange",
            "yellow"
        ];
        return bgColors[index];
    }
    function backgroundTimer(uint256 index)
        internal
        pure
        returns (string memory)
    {
        string[7] memory bgTimes = [
            "s",
            "s",
            "s",
            "s",
            "m",
            "m",
            "h"
        ];
        return bgTimes[index];
    }
    function stopOpacityPicker(uint256 index)
        internal
        pure
        returns (string memory)
    {
        string[10] memory stopOpacity = [
            "0.1",
            "0.2",
            "0.3",
            "0.4",
            "0.5",
            "0.6",
            "0.7",
            "0.8",
            "0.9",
            "1.0"
        ];
        return stopOpacity[index];
    }
    function svgToImageURI(string memory _svg)
        public
        
        returns (string memory)
    {
        string memory svg = getSvg();
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function getSvg() public returns (string memory) {
//        string memory svg = "<?xml version='1.0' standalone='no'?> <svg xmlns='http://www.w3.org/2000/svg'  xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 24 24'> <defs> <linearGradient id='a' gradientUnits='objectBoundingBox' x1='0' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='red'> <animate attributeName='stop-color' values='red;purple;blue;green;yellow;orange;red;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='.5' stop-color='purple'> <animate attributeName='stop-color' values='purple;blue;green;yellow;orange;red;purple;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='1' stop-color='blue'> <animate attributeName='stop-color' values='blue;green;yellow;orange;red;purple;blue;' dur='200s' repeatCount='indefinite'> </animate> </stop> <animateTransform attributeName='gradientTransform' type='rotate' from='0 .5 .5' to='360 .5 .5' dur='300s' repeatCount='indefinite' /> </linearGradient> <linearGradient id='b' gradientUnits='objectBoundingBox' x1='0' y1='1' x2='1' y2='1'> <stop offset='0' stop-color='red'> <animate attributeName='stop-color' values='red;purple;blue;green;yellow;orange;red;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='1' stop-color='purple' stop-opacity='0'> <animate attributeName='stop-color' values='purple;blue;green;yellow;orange;red;purple;' dur='200s' repeatCount='indefinite'> </animate> </stop> <animate Transform='gradientTransform' type='rotate' values='360 .5 .5;0 .5 .5' dur='400s' repeatCount='indefinite' /> </linearGradient> </defs> <rect fill='url(#a)' width='100%' height='100%' /> <rect fill='url(#b)' width='100%' height='100%' /> </svg>";

        string memory svg = buildSvg();

        return svg;
    }

    function buildColorStops() public returns (string memory) {
//        string memory svg = "<?xml version='1.0' standalone='no'?> <svg xmlns='http://www.w3.org/2000/svg'  xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 24 24'> <defs> <linearGradient id='a' gradientUnits='objectBoundingBox' x1='0' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='red'> <animate attributeName='stop-color' values='red;purple;blue;green;yellow;orange;red;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='.5' stop-color='purple'> <animate attributeName='stop-color' values='purple;blue;green;yellow;orange;red;purple;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='1' stop-color='blue'> <animate attributeName='stop-color' values='blue;green;yellow;orange;red;purple;blue;' dur='200s' repeatCount='indefinite'> </animate> </stop> <animateTransform attributeName='gradientTransform' type='rotate' from='0 .5 .5' to='360 .5 .5' dur='300s' repeatCount='indefinite' /> </linearGradient> <linearGradient id='b' gradientUnits='objectBoundingBox' x1='0' y1='1' x2='1' y2='1'> <stop offset='0' stop-color='red'> <animate attributeName='stop-color' values='red;purple;blue;green;yellow;orange;red;' dur='200s' repeatCount='indefinite'> </animate> </stop> <stop offset='1' stop-color='purple' stop-opacity='0'> <animate attributeName='stop-color' values='purple;blue;green;yellow;orange;red;purple;' dur='200s' repeatCount='indefinite'> </animate> </stop> <animate Transform='gradientTransform' type='rotate' values='360 .5 .5;0 .5 .5' dur='400s' repeatCount='indefinite' /> </linearGradient> </defs> <rect fill='url(#a)' width='100%' height='100%' /> <rect fill='url(#b)' width='100%' height='100%' /> </svg>";

        string memory gradient_ColorStop = (string(abi.encodePacked(backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)))));

        return gradient_ColorStop;
    }
    function buildSvg() public returns (string memory) {
        uint stopColor1 = randMod(12);
        uint stopColor2 = randMod(12);
        uint stopColor3 = randMod(12);
        uint stopColor4 = randMod(12);
        uint stopColor5 = randMod(12);
//        string memory gradient_ColorStop = (string(abi.encodePacked(backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)), ";", backgroundColors(randMod(12)))));
        string memory gradient_ColorStop = buildColorStops();

        string memory header = "<?xml version='1.0' standalone='no'?> <svg xmlns='http://www.w3.org/2000/svg'  xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 24 24'> <defs> ";
//        string memory gradient1_Stop1Builder = (string(abi.encodePacked("<linearGradient id='a' gradientUnits='objectBoundingBox' x1='0' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='red'> <animate attributeName='stop-color' values='red;purple;blue;green;yellow;orange;red;' dur='", uint2str(durationRand1), "s' repeatCount='indefinite'> </animate> </stop> ")));
        string memory gradient1_Stop1Builder = (string(abi.encodePacked("<linearGradient id='a' gradientUnits='objectBoundingBox' x1='1' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='", backgroundColors(stopColor1), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor1), ";", gradient_ColorStop, ";", backgroundColors(stopColor1), ";' dur='", uint2str(durationRand1), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        string memory gradient1_Stop2Builder = (string(abi.encodePacked("<stop offset='.5' stop-color='", backgroundColors(stopColor2), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor2), ";", gradient_ColorStop, ";", backgroundColors(stopColor2), ";' dur='", uint2str(durationRand1), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        string memory gradient1_Stop3Builder = (string(abi.encodePacked("<stop offset='1' stop-color='", backgroundColors(stopColor3), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor3), ";", gradient_ColorStop, ";", backgroundColors(stopColor3), ";' dur='", uint2str(durationRand1), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        string memory gradient1Transform = (string(abi.encodePacked("<animateTransform attributeName='gradientTransform' type='rotate' from='0 .5 .5' to='360 .5 .5' dur='", uint2str(durationRand2), backgroundTimer(randMod(7)), "' repeatCount='indefinite' /> </linearGradient> ")));
//        string memory gradient2_Stop1Builder = (string(abi.encodePacked("<linearGradient id='b' gradientUnits='objectBoundingBox' x1='1' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='", backgroundColors(stopColor1), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor1), ";", gradient_ColorStop, ";", backgroundColors(stopColor1), ";' dur='", uint2str(durationRand1), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        gradient2_Stop1Builder = (string(abi.encodePacked("<linearGradient id='b' gradientUnits='objectBoundingBox' x1='1' y1='0' x2='1' y2='1'> <stop offset='0' stop-color='", backgroundColors(stopColor4), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor4), ";", gradient_ColorStop, ";", backgroundColors(stopColor4), ";' dur='", uint2str(durationRand1), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        gradient2_Stop2Builder = (string(abi.encodePacked("<stop offset='1' stop-color='", backgroundColors(stopColor5), "' stop-opacity='", stopOpacityPicker(randMod(10)), "'> <animate attributeName='stop-color' values='", backgroundColors(stopColor5), ";", gradient_ColorStop, ";", backgroundColors(stopColor5), ";' dur='", uint2str(durationRand2), backgroundTimer(randMod(7)), "' repeatCount='indefinite'> </animate> </stop> ")));
        string memory gradient2Transform = (string(abi.encodePacked("<animate Transform='gradientTransform' type='rotate' values='360 .5 .5;0 .5 .5' dur='", uint2str(durationRand3), backgroundTimer(randMod(7)), "' repeatCount='indefinite' /> </linearGradient> </defs> ")));
        string memory closer = (string(abi.encodePacked("<rect fill='url(#a)' width='100%' height='100%' /> <rect fill='url(#b)' width='100%' height='100%' /> </svg>")));
        string memory svg = (string(abi.encodePacked(header, gradient1_Stop1Builder, gradient1_Stop2Builder, gradient1_Stop3Builder)));
        svg = (string(abi.encodePacked(svg, gradient1Transform)));
        svg = (string(abi.encodePacked(svg, gradient2_Stop1Builder, gradient2_Stop2Builder)));
        svg = (string(abi.encodePacked(svg, gradient2Transform)));
        svg = (string(abi.encodePacked(svg, closer)));


        return svg;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////   tokenURI Function   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        bool _switchOn = attributes[tokenId].switchOn;
        string memory _imageURI;
        bool _svgOn = attributes[tokenId].svg_True_False;
        uint256 _switchPoint = attributes[tokenId].switchPoint;

        if (_svgOn == true) {
            _imageURI = attributes[tokenId].SVG_Image;
        } else {
            _imageURI = attributes[tokenId].imageA;
            if (_switchOn == true) {
                if (imageRand >= _switchPoint) {
                    _imageURI = attributes[tokenId].imageB;
                }
            }
        }

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        buildName(tokenId),
                        '",',
                        '"image": "',
                        _imageURI,
                        '",',
                        '"attributes": [{"trait_type": "edition", "value": ',
                        uint2str(attributes[tokenId].edition),
                        "},",
                        '{"trait_type": "masterNumber", "value": ',
                        uint2str(attributes[tokenId].masterNumber),
                        "},",
                        '{"trait_type": "switchPoint", "value": ',
                        uint2str(attributes[tokenId].switchPoint),
                        "}",
                        "]}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //only owner 
    //set functions
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setinterval(uint256 _interval) public onlyOwner {
        interval = _interval;
    }

    function setcounter(uint256 _setcounter) public onlyOwner {
        counter = _setcounter;
    }

    function setrandomRange(uint256 _setrandomRange) public onlyOwner {
        randomRange = _setrandomRange;
    }

    function setauctionDuration(uint256 _auctionDuration) public onlyOwner {
        auctionDuration = _auctionDuration;
    }


    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setbaseCost(uint256 _baseCost) public onlyOwner {
        baseCost = _baseCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setmaxDailyCopies(uint256 _newmaxDailyCopies) public onlyOwner {
        maxDailyCopies = _newmaxDailyCopies;
    }

    function setcostMultiplier(uint256 _newcostMultiplier) public onlyOwner {
        costMultiplier = _newcostMultiplier;
    }

    function setstagingURI(
        string memory _stagingURI,
        string memory _stagingName
    ) public onlyOwner {
        stagingName = _stagingName;
        stagingURI = _stagingURI;
    }

    function setauctionURI(
        string memory _newauctionURI,
        string memory _newauctionName
    ) public onlyOwner {
        auctionURI = _newauctionURI;
        auctionName = _newauctionName;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }





    function reveal() public onlyOwner {
        revealed = true;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function turn_svgOn(bool _svgSwitch_On) public onlyOwner {
        svgOn = _svgSwitch_On;
    }
    function set_switchOn(bool _Set_Switch_On) public onlyOwner {
        switchOn = _Set_Switch_On;
    }

    function withdraw() public payable onlyOwner {
        // This will pay TheNewGuy 15% of the initial sale.
        // =============================================================================
        (bool hs, ) = payable(0xa9fa85E69aedA99bd5B388A427aEbe3D02bAD7A5).call{
            value: (address(this).balance * 15) / 100
        }("");
        require(hs);
        // This will pay LessThanVinnie 15% of the initial sale.
        // =============================================================================
        (bool lv, ) = payable(0x31493a1D44984a700ADa235f190bDd1D0d9a3C8C).call{
            value: (address(this).balance * 15) / 100
        }("");
        require(lv);

        // This will payout the owner 60% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
