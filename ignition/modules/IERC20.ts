import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const IERC20Module = buildModule("IERC20Module", (m) => {

  const IERC20 = m.contract("NomCoin");

  return { IERC20 };
});

export default IERC20Module;