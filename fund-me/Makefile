-include .env

build:; forge build

deplou-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url ${SEPOLIA_RPC_URL}
	--private-key ${PRIVATE_KEY} --broadcast --varify --etherscan-api-key
	${ETHERSCAN_API_KEY} -vvvv