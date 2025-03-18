const { ethers, upgrades } = require("hardhat");

// testnet 0xBB83c12a48f7E84cD3c249039d579013D3a59255
// mainnet 0x3eEAebc3F3360F297dcd1FfBC69ACB2ED1E11A4A

async function main() {

    const PowerBankDemo = await ethers.getContractFactory("PowerBankDemo");
    const instance = await upgrades.upgradeProxy("0x3eEAebc3F3360F297dcd1FfBC69ACB2ED1E11A4A", PowerBankDemo);
    await instance.waitForDeployment();
    console.log("PowerBankDemo upgrade to:", instance.target);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });