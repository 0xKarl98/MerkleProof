include "./mimc.circom";

/*
 * IfThenElse sets `out` to `true_value` if `condition` is 1 and `out` to
 * `false_value` if `condition` is 0.
 *
 * It enforces that `condition` is 0 or 1.
 *
 */
template IfThenElse() {
    signal input condition; // 0 or 1 
    signal input true_value;
    signal input false_value;
    signal  helper ;
    signal output out;


    condition * (condition - 1) === 0 ; // enforce condition be 0/1
    if (condition ==1 ){
        helper <== true_value ;
    } else { 
        helper <== false_value ;
        
    }
        out <== helper ;

}


template SelectiveSwitch() {
    signal input in0;
    signal input in1;
    signal input s;
    signal output out0;
    signal output out1;


    // enfoce s to be 0 or 1 
    s * (s - 1) === 0 ;
 
 //If the "select" (`s`) input is 1, then it inverts the order of the inputs
 //* in the ouput. If `s` is 0, then it preserves the order.
    if (s === 1)
    {
       out0 <== int 1;
       out1 <== int 0;   
    }  else {
        out0 <== int 0;
        out1 <== int 1;
    }
   
    
}

/*
 * Verifies the presence of H(`nullifier`, `nonce`) in the tree of depth
 * `depth`, summarized by `digest`.
 * This presence is witnessed by a Merle proof provided as
 * the additional inputs `sibling` and `direction`, 
 */
template Spend(depth) {
    // Merkle tree root 
    signal input digest;
    //reveal nullifier , allows everyone to check if it is unspent .
    signal input nullifier; 
    //Use to prove in zk , that corresponding coin exits . 
    signal private input nonce;
    signal private input sibling[depth];
    // indicating the sibling's direction , 0/1 for left/right 
    signal private input direction[depth];
    
    // Indicating coin = H(nullifier , nonce)
    component hashLeaf = Mimc2() ;
    hashLeaf.in0 <== nullifier ;
    hashLeaf.in1 <== nonce ;

    component hashers[depth];
    component selectors[depth];
    
    for (var i=0 ; i<depth; i++){
        
        log(hashLeaf.out) ;

        selectors[i] = SelectiveSwitch() ;
        selectors[i].in0 <==  i == 0 ? hashleaf.out : hashleaf[i-1].out ;
        selectors[i].in1 <== sibling[i];
        selectors[i].s <== direction[i];

        hashers[i] = Mimc2();
        hashers[i].in0 <== selectors[i].out0;
        hashers[i].in1 <== selectors[i].out1;
        log(hashers[i].out);

  }
   digest === hashers[depth].out;
    

    
    

   
 
    
    
    
}

