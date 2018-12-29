import web3 from "./index"
import blindAutionArtifacts from "../../../build/contracts/BlindAuction.json"
import contract from "truffle-contract"

let BlindAuction = contract(blindAutionArtifacts)

BlindAuction.setProvider(web3.currentProvider)

export default BlindAuction