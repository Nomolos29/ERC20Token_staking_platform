import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const ERC20TokenStakingContractModule = buildModule("ERC20TokenStakingContractModule", (m) => {

  const ERC20TokenStakingContract = m.contract("ERC20TokenStakingContract",["0x463d9dfE9A750fC8D7708613D8D9a000F7BC2610"]);

  return { ERC20TokenStakingContract };
});

export default ERC20TokenStakingContractModule;