// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 16570489026739502590424379524387652771445514258584753945881435610445114837029;
    uint256 constant alphay  = 1514618790105882438715508927457705354301619136135694730625677830163796094445;
    uint256 constant betax1  = 6007971149428524966980322280483914428372031894440561394400401304531847429327;
    uint256 constant betax2  = 5119776702648060732127250970793622645126165624438185978985152215095272464869;
    uint256 constant betay1  = 16124860358520120436199233684236659334548794044557194399600659916253918118849;
    uint256 constant betay2  = 959609275338094747150193478370575641861722439037095519185236563487017771491;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 6918022788356888436314507232227491305912330775650159163065015461558426360122;
    uint256 constant deltax2 = 5039835504970449195084386224315458544081579504970884631891634745263903984138;
    uint256 constant deltay1 = 17167477328729706203299206464922660825496363424863096062660985060501901880404;
    uint256 constant deltay2 = 17540841617699486702961509967296576202282383743742062519101267887895657229761;

    
    uint256 constant IC0x = 11863504107419585798091908800515411043585003420315286317464963423372072065292;
    uint256 constant IC0y = 14742992469121984130376076973826258777933584689929477428677591671383994353844;
    
    uint256 constant IC1x = 13831791330769731565915387349683306806358066392488889263286836079152133841382;
    uint256 constant IC1y = 6922918123754693326206574790722064240424481560523181798521109062552608050685;
    
    uint256 constant IC2x = 4333682067707910588086193019994319949214461046456891748658849047401297197224;
    uint256 constant IC2y = 4049680626409967993666154433654419303576528943453031902441961749152309744798;
    
    uint256 constant IC3x = 14797048269808822495714805461289895774865337638320451988823138658164319095927;
    uint256 constant IC3y = 9807005049987833663066357785154919036069260705807715681570409401958883461455;
    
    uint256 constant IC4x = 5342890756902046892483080100927267589409188692860389254464750212669903742824;
    uint256 constant IC4y = 7387674654540947856760553572096138462614304966316959218380104787426663238022;
    
    uint256 constant IC5x = 18438413282846571608081669283707175606696479045282597018328694931298220910576;
    uint256 constant IC5y = 7428159359530588020315189625441811418678985328909272394098357020550440977037;
    
    uint256 constant IC6x = 12572717320954232747015447537749339250252613949025109206529342808637555395116;
    uint256 constant IC6y = 2313198796653574219407214441733054835229040381952586393231169842192001532645;
    
    uint256 constant IC7x = 11819322072825218150148191734541597373309863029246107439403662000771160949081;
    uint256 constant IC7y = 6620693748992769596224747812437205701546491751099547036943941231668763111927;
    
    uint256 constant IC8x = 15469741112139754019707087222283038880100501351321964030989449315255208403691;
    uint256 constant IC8y = 11646210982306407481921413382122135223353829494044921537617999219189515104268;
    
    uint256 constant IC9x = 15414183753828704631076697919736641848363231102212194855612487091827291217606;
    uint256 constant IC9y = 11080801531446309026143653957580167631715005534124411834474985201268828377892;
    
    uint256 constant IC10x = 18540542224216822467211988055029793190203445393748608828630942627089914072694;
    uint256 constant IC10y = 12218365163965385985307752305899100829014488321502949753490463947963217891526;
    
    uint256 constant IC11x = 9896062563356752042245221957535144787584607112907355156905534709509690247113;
    uint256 constant IC11y = 16492067605820570239876577881927373556445799820990004279048095615153547050778;
    
    uint256 constant IC12x = 5484436388685918017146226875509212385373453379769864008991971970522384167092;
    uint256 constant IC12y = 11913743102834405884049620722025903194407029515276642392390512315155078547097;
    
    uint256 constant IC13x = 17811285399087334028942073630047475723007806570170383253651697276780470075732;
    uint256 constant IC13y = 15979252373445409431141662170298148071720569146232979858459202736427500339653;
    
    uint256 constant IC14x = 14860785489149246113490919470366831478143341956206286775300479120142998829025;
    uint256 constant IC14y = 12155951714848550139343082369056666854052373898078224188809143967316234627522;
    
    uint256 constant IC15x = 14008496639816730153946785651519837219509581791813318662517499943162450531686;
    uint256 constant IC15y = 3921154278557314350226431585152707553734252618740995795965448239707241289019;
    
    uint256 constant IC16x = 11351067162239430583150855900416763425724441133014500679145802895593661902759;
    uint256 constant IC16y = 7740987064420740233073622149485039566300028633290759781868077611528014064862;
    
    uint256 constant IC17x = 17019228811739868423245552760389779900329782765914306838679060923965268632676;
    uint256 constant IC17y = 463534537138712194992620903125591970500080809820623300590260022461404296055;
    
    uint256 constant IC18x = 17034681553197779690659917421551928185534236459129620148646035040113388540540;
    uint256 constant IC18y = 21023210842306963975084690657070541860830475805358261125728934775145505163863;
    
    uint256 constant IC19x = 1396192684074380930116945160552004163500220346307193540169009371290293684079;
    uint256 constant IC19y = 17910347983212514634917092257409185115134010225928900536913291296426007242270;
    
    uint256 constant IC20x = 15389426495448677742044336756383635194731705031148343154160841716249946407793;
    uint256 constant IC20y = 5078835074704453661060678797866726868385806893347229775345861015528437210346;
    
    uint256 constant IC21x = 2090357838224458520841159170414024269978410863260531355114111784534728373217;
    uint256 constant IC21y = 14391659651512152767665281950975484839450038078515026377823682014490636312293;
    
    uint256 constant IC22x = 12616241873404065763402043827589065168846054520723481925042478870352664747285;
    uint256 constant IC22y = 13172781593408836762458211262445693155605744386493371276611798540896715879085;
    
    uint256 constant IC23x = 8228921198952609416006363934289473134653506432241935619940605416056503243294;
    uint256 constant IC23y = 6521377776614433408461992370998762627414982412372692934911836970737126456892;
    
    uint256 constant IC24x = 5238511735828630171409728361269479516937629432636659885405150063072080569573;
    uint256 constant IC24y = 13344221897867951475333237012181675565145502967467385398581555630736120352722;
    
    uint256 constant IC25x = 1494514653079063474391899353188580333521855669164704695327916702883721639838;
    uint256 constant IC25y = 8485820387473706450790203071343530406506609293567103983642657445428913916980;
    
    uint256 constant IC26x = 9397185824762780036490960315789333275397238569801970073709725262048545751500;
    uint256 constant IC26y = 8387372425295340223336603774813958013346413270268355328263040839241973141506;
    
    uint256 constant IC27x = 20577221250808251347790033540184272312837448085297559032984165518452853549270;
    uint256 constant IC27y = 16296842481411531133823722566527077544194731670783455192353196410701867901828;
    
    uint256 constant IC28x = 11929180765093147586650910174683360488003755621389237584940463174965607889210;
    uint256 constant IC28y = 16240445582877622832422637371120138189027442033559847839751501656048573751319;
    
    uint256 constant IC29x = 677016339448801619459696297727108147599567562163587163986076553111275042322;
    uint256 constant IC29y = 794965143684424961590879628440880966738657709662111392397993175329721838462;
    
    uint256 constant IC30x = 889652148436557089949488043291898652952496845750516514994276530514788669671;
    uint256 constant IC30y = 15809067458148915219694546039186509166801664663032258563992254319294067062247;
    
    uint256 constant IC31x = 15871599471143399702562024717336547533527314864024881945582215683601517889645;
    uint256 constant IC31y = 12167695596859560509547123027040987757097901072188533441626302524617860041212;
    
    uint256 constant IC32x = 2351840889632481723666578741563789775820396862176433998270263931537682009516;
    uint256 constant IC32y = 13896669883608607494660161483052176078629589784765906327887495324222251718239;
    
    uint256 constant IC33x = 13291631945828569298907499311297321863200742821969168668104398007981098690818;
    uint256 constant IC33y = 10253780915538382923027269801471132921625456946304721585644940991921509249884;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[33] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
