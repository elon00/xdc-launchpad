import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys the XDCLaunchpadToken contract using the deployer account
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployXDCLaunchpadToken: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  console.log("Deploying XDCLaunchpadToken with deployer:", deployer);

  await deploy("XDCLaunchpadToken", {
    from: deployer,
    args: [deployer], // Constructor takes initialOwner
    log: true,
    autoMine: true,
  });

  // Get the deployed contract
  const tokenContract = await hre.ethers.getContract<Contract>("XDCLaunchpadToken", deployer);
  const totalSupply = await tokenContract.totalSupply();
  console.log("🚀 XDCLaunchpadToken deployed!");
  console.log("📊 Total Supply:", hre.ethers.formatEther(totalSupply), "XDCLP");
  console.log("👤 Owner:", await tokenContract.owner());
};

export default deployXDCLaunchpadToken;

deployXDCLaunchpadToken.tags = ["XDCLaunchpadToken"];