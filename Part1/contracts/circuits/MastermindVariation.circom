pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

// My choice is Super Mastermind, which has 5 pegs and 8 colors.
// And the colors in pegs can have duplication.
template MastermindVariation() {
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubGuessD;
    signal input pubGuessE;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privSolnD;
    signal input privSolnE;
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[5] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE];
    var soln[5] =  [privSolnA, privSolnB, privSolnC, privSolnD, privSolnE];
    component lessThan[10];

    // Create a constraint that the solution and guess digits are all less than 8.
    var j=0, k=0;
    for (j=0; j<5; j++) {
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 8;
        lessThan[j].out === 1;
        lessThan[j+5] = LessThan(4);
        lessThan[j+5].in[0] <== soln[j];
        lessThan[j+5].in[1] <== 8;
        lessThan[j+5].out === 1;
    }

    // Count hit & blow
    var hit = 0;
    var blow = 0;
    component equalHB[5*5];

    for (j=0; j<5; j++) {
        for (k=0; k<5; k++) {
            equalHB[5*j+k] = IsEqual();
            equalHB[5*j+k].in[0] <== soln[j];
            equalHB[5*j+k].in[1] <== guess[k];
            blow += equalHB[5*j+k].out;
            if (j == k) {
                hit += equalHB[5*j+k].out;
                blow -= equalHB[5*j+k].out;
            }
        }
    }

    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(6);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
    poseidon.inputs[4] <== privSolnD;
    poseidon.inputs[5] <== privSolnE;

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
}

component main {public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE, pubNumHit, pubNumBlow, pubSolnHash]} = MastermindVariation();
