// [bonus] unit test for bonus.circom

const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Takuzu circuit test", function () {
    this.timeout(100000000);

    it("8 colors and 5 pegs", async () => {
        const circuit = await wasm_tester("contracts/circuits/bonus.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "breakAnswer": [
                ["0", "1", "1", "0"],
                ["1", "0", "0", "1"],
                ["0", "0", "1", "1"],
                ["1", "1", "0", "0"],
            ],
            "makerHash": "20754129533319145634200824190489482497008085703026360158113906748634722678486",

            "makerAnswer": [
                ["0", "1", "1", "0"],
                ["1", "0", "0", "1"],
                ["0", "0", "1", "1"],
                ["1", "1", "0", "0"],
            ],
            "makerSalt": "42342312212930",
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        // console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),Fr.e(
            Scalar.fromString(INPUT["makerHash"])
            )));
    });
});
