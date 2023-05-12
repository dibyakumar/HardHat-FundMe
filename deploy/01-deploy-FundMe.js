//async function deployFunction(hre){
//     console.log("Hii")
// }
// module.exports.default = deployFunction

//Or

// module.exports = async (hre)=>{
//     const {getNamedAccounts,deployments} = hre
//     /** Above same as
//      * hre.getNamesAccounts
//      * hre.deployments
//      */
// }

//The above can be written as

const { networkConfig, developmentChain } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //const ethUsdPriceFeedAddress = networkConfig[chainId][ethUsdPriceFeed]
    let ethUsdPriceFeedAddress
    if (developmentChain.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("mockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, // we will put the data which needs to pass in the constructor
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChain.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }

    log("-------------------------------------------------")
}
module.exports.tags = ["all", "fundme"]
