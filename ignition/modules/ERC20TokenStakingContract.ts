import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const ERC20TokenStakingContractModule = buildModule("ERC20TokenStakingContractModule", (m) => {

  const ERC20TokenStakingContract = m.contract("NomCoinMining");

  return { ERC20TokenStakingContract };
});

export default ERC20TokenStakingContractModule;