//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Mastermind variation circuit test", function () {
    this.timeout(100000000);

    it("8 colors and 5 pegs", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "pubGuessA": "6",
            "pubGuessB": "3",
            "pubGuessC": "4",
            "pubGuessD": "1",
            "pubGuessE": "0",
            "pubNumHit": "4",
            "pubNumBlow": "0",
            "pubSolnHash": "1153714995868432001483397819670001450676359236455243657131706950942774564342",

            "privSolnA": "6",
            "privSolnB": "3",
            "privSolnC": "4",
            "privSolnD": "1",
            "privSolnE": "5",
            "privSalt": "4113922342"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        // console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),Fr.e(
            Scalar.fromString(INPUT["pubSolnHash"])
            )));
    });
});
