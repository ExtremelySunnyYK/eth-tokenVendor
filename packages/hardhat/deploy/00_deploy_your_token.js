// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("YourToken", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    log: true,
  });

  const yourToken = await ethers.getContract("YourToken", deployer);

  // If you want to send some ETH to a contract on deploy (make your constructor payable!);
  // const yourContract = await deploy("yourToken", [], {
  //   value: ethers.utils.parseEther("0.05"),
  // });

  // Todo: transfer tokens to frontend address
  const result = await yourToken.transfer(
    "0x22f4E5A44413b39cd725eb1632a17e27AfBa8A88",
    ethers.utils.parseEther("1000")
  );

  // ToDo: To take ownership of yourToken using the ownable library uncomment next line and add the
  // address you want to be the owner.
  yourToken.transferOwnership("0x22f4E5A44413b39cd725eb1632a17e27AfBa8A88");

  // if you want to instantiate a version of a contract at a specific address!
  // const yourToken = await ethers.getContractAt('yourToken', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A");

  // If you want to send value to an address from the deployer
  // const deployerWallet = ethers.provider.getSigner();
  // await deployerWallet.sendTransaction({
  //   to: "0x22f4E5A44413b39cd725eb1632a17e27AfBa8A88",
  //   value: ethers.utils.parseEther("0.001"),
  // });

  // If you want to link a library into your contract:
  // const yourToken = await deploy("yourToken", [], {}, {
  //  LibraryName: **LibraryAddress**
  // });

  // ToDo: Verify your contract with Etherscan for public chains
  if (chainId !== "31337") {
    try {
      console.log(" 🎫 Verifing Contract on Etherscan... ");
      await sleep(5000); // wait 5 seconds for deployment to propagate
      await run("verify:verify", {
        address: yourToken.address,
        contract: "contracts/YourToken.sol:YourToken",
        contractArguments: [],
      });
    } catch (e) {
      console.log(" ⚠️ Failed to verify contract on Etherscan ");
    }
  }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["YourToken"];
