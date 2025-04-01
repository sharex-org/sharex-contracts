const { ethers, upgrades } = require("hardhat");

// testnet 0xBB83c12a48f7E84cD3c249039d579013D3a59255
// mainnet 0x3eEAebc3F3360F297dcd1FfBC69ACB2ED1E11A4A
// bnbmainnet 0x3eEAebc3F3360F297dcd1FfBC69ACB2ED1E11A4A

async function main() {
    // get signer
    const [signer] = await ethers.getSigners();
    const signerAddress = await signer.getAddress();
    console.log("Signer address:", signerAddress);

    // get signer balance
    const signerBalance = await ethers.provider.getBalance(signerAddress);
    console.log("Signer balance:", signerBalance);

    // deploy PowerBankDemo contract
    const PowerBankDemo = await ethers.getContractFactory("PowerBankDemo");
    const instance = await upgrades.deployProxy(PowerBankDemo, [], { 
        initializer: 'initialize',
     });
    await instance.waitForDeployment();
    console.log("PowerBankDemo deployed to:", instance.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
