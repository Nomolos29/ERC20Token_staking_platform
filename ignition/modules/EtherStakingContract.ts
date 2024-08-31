import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const EtherStakingContractModule = buildModule("EtherStakingContractModule", (m) => {

  const EtherStakingContract = m.contract("stakeEther");

  return { EtherStakingContract };
});

export default EtherStakingContractModule;