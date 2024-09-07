const { ethers, upgrades } = require("hardhat");

// testnet 0x6fD95f5Ff9742819561E5b68FdFA15F69bE7e1a7

async function main() {
    // deploy PowerBankDemo contract
    const PowerBankDemo = await ethers.getContractFactory("PowerBankDemo");
    const instance = await upgrades.deployProxy(PowerBankDemo, [], { initializer: 'initialize' });
    await instance.waitForDeployment();
    console.log("PowerBankDemo deployed to:", instance.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
