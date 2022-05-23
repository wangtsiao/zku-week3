// [bonus] implement an example game from part d
// Takuzu

pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";

template IsZeroOrOne() {
    signal input in;
    signal output out;
    
    component or = OR();
    component isZero = IsZero();
    component isEqual = IsEqual();
    isZero.in <== in;
    or.a <== isZero.out;
    isEqual.in[0] <== 1;
    isEqual.in[1] <== in;
    or.b <== isEqual.out;

    out <== or.out;
}

template Takuzu(n) {
    assert(n&1==0);
    assert(n > 0);
    assert(n <= 14);

    
    // public inputs
    signal input breakAnswer[n][n];
    signal input makerHash;

    // private inputs
    signal input makerAnswer[n][n];
    signal input makerSalt;
    
    // output
    signal output makerHashOut;

    
    // check a contraint that these digits are all 1 or 0. and check if equal.
    component isZeroOrOne[n][n];
    var j = 0, k = 0;
    for (j=0; j<n; j++) {
        for (k =0; k<n; k++) {
            breakAnswer[j][k] === makerAnswer[j][k];

            isZeroOrOne[j][k] = IsZeroOrOne();
            
            isZeroOrOne[j][k].in <== breakAnswer[j][k];
            isZeroOrOne[j][k].out === 1;
        }
    }

    component poseidon = Poseidon(2);
    var flatten = 1;
    for (j=0; j<n; j++) {
        for (k=0; k<n; k++) {
            flatten <<= 1;
            flatten = makerAnswer[j][k];
        }
    }

    poseidon.inputs[0] <== flatten;
    poseidon.inputs[1] <== makerSalt;

    makerHashOut <== poseidon.out;
    makerHash === makerHashOut;
}

component main {public [breakAnswer, makerHash] } = Takuzu(4);