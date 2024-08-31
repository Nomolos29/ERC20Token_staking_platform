import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const ERC20TokenStakingContractModule = buildModule("ERC20TokenStakingContractModule", (m) => {

  const ERC20Token = m.contract("ERC20TokenStakingContractModule");

  return { ERC20Token };
});

export default ERC20TokenStakingContractModule;