pragma solidity ^0.8.7;

interface ISimple {
    function doesntMatter() external view returns (uint256);
}

contract CallSimple {
    ISimple public target;

    constructor(ISimple _target){
        target = _target;
    }

    function updateTarget(ISimple _target) external {
        target = _target;
    }

    function callSimple() external view returns (uint256) {
        return target.doesntMatter();
    }
}
