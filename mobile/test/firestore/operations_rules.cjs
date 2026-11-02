const assert=require('node:assert/strict');
const root='projects/demo-dairytrace/databases/(default)/documents';
const base=`http://127.0.0.1:18080/v1/${root}`;
const now=Math.floor(Date.now()/1000);
const encode=v=>Buffer.from(JSON.stringify(v)).toString('base64url');
const token=uid=>`${encode({alg:'none',typ:'JWT'})}.${encode({iss:'https://securetoken.google.com/demo-dairytrace',aud:'demo-dairytrace',sub:uid,user_id:uid,iat:now,exp:now+3600,auth_time:now,firebase:{sign_in_provider:'custom',identities:{}}})}.`;
const field=v=>Array.isArray(v)?{arrayValue:{values:v.map(field)}}:v instanceof Date?{timestampValue:v.toISOString()}:typeof v==='number'?{doubleValue:v}:{stringValue:v};
const fields=o=>Object.fromEntries(Object.entries(o).map(([k,v])=>[k,field(v)]));
function write(path,data,transforms=[],update=false){return {update:{name:`${root}/${path}`,fields:fields(data)},...(update?{updateMask:{fieldPaths:Object.keys(data)}}:{currentDocument:{exists:false}}),...(transforms.length?{updateTransforms:transforms.map(fieldPath=>({fieldPath,setToServerValue:'REQUEST_TIME'}))}:{})};}
async function commit(writes,uid='owner'){return fetch(`${base}:commit`,{method:'POST',headers:{'Content-Type':'application/json',...(uid?{Authorization:`Bearer ${token(uid)}`}:{})},body:JSON.stringify({writes})});}
async function expect(p,status,label){const r=await p;const body=await r.text();assert.equal(r.status,status,`${label}: ${body}`);console.log(`PASS: ${label}`);}
const date=new Date('2026-10-25T04:00:00Z');
const collection={farmerName:'Rajesh Kumar',quantityLitres:12,createdBy:'owner',collectionDate:date,fat:4,snf:8.5,temperature:6,qualityStatus:'ACCEPTED',farmerId:'op-farmer',centerId:'op-center',centerName:'Green Valley',session:'MORNING',dayKey:'2026-10-25',notes:''};
const batch=(ids)=>({createdBy:'owner',collectionIds:ids,centerId:'op-center',session:'MORNING',dayKey:'2026-10-25',status:'PENDING'});
(async()=>{
 await expect(commit([write('collectionCenters/op-center',{createdBy:'owner',name:'Green Valley',village:'Rampur',status:'ACTIVE'},['createdAt'])]),200,'register centre');
 await expect(commit([write('farmers/op-farmer',{createdBy:'owner',name:'Rajesh Kumar',village:'Rampur',phone:'9876543210',centerId:'op-center',status:'ACTIVE'},['createdAt'])]),200,'register farmer');
 for(let i=0;i<10;i++) await expect(commit([write(`collections/op-${i}`,collection,['createdAt'])]),200,`linked collection ${i}`);
 await expect(commit([write('collections/op-forged',{...collection,farmerName:'Forged name'},['createdAt'])]),403,'forged farmer snapshot denied');
 await expect(commit([write('collections/op-foreign',{...collection,createdBy:'other'},['createdAt'])],'other'),403,'foreign directory link denied');
 await expect(commit([write('collections/op-preassigned',{...collection,batchId:'fake'},['createdAt'])]),403,'preassigned batch denied');
 await expect(commit([write('collections/op-0',{quantityLitres:99},[],true)]),403,'registered source alteration denied');
 await expect(commit([write('batches/op-invalid',batch(['op-0']),['createdAt'])]),403,'batch without atomic source assignment denied');
 await expect(commit([write('batches/op-good',batch(['op-0','op-1']),['createdAt']),write('collections/op-0',{batchId:'op-good'},[],true),write('collections/op-1',{batchId:'op-good'},[],true)]),200,'atomic compatible batch');
 await expect(commit([write('batches/op-reused',batch(['op-0']),['createdAt']),write('collections/op-0',{batchId:'op-reused'},[],true)]),403,'collection cannot belong to second batch');
 await expect(commit([write('batches/op-good',{collectionIds:['op-0']},[],true)]),403,'batch membership cannot change');
 await expect(commit([write('batches/op-good',{status:'FAILED',testNotes:'Temperature failed',testedBy:'owner'},['testedAt'],true)]),200,'quality result with tester');
 await expect(commit([write('batches/op-good',{status:'PASSED',testNotes:'Overwrite result',testedBy:'owner'},['testedAt'],true)]),403,'final test cannot be overwritten');
 await expect(commit([write('collections/op-evening',{...collection,session:'EVENING'},['createdAt'])]),200,'evening record');
 await expect(commit([write('batches/op-mixed',batch(['op-2','op-evening']),['createdAt']),write('collections/op-2',{batchId:'op-mixed'},[],true),write('collections/op-evening',{batchId:'op-mixed'},[],true)]),403,'mixed sessions denied');
 const ids=Array.from({length:8},(_,i)=>`op-${i+2}`);
 await expect(commit([write('batches/op-eight',batch(ids),['createdAt']),...ids.map(id=>write(`collections/${id}`,{batchId:'op-eight'},[],true))]),200,'maximum eight-source batch fits rules access budget');
 const dispute={collectionId:'op-0',type:'Quantity',description:'Please verify weight',status:'OPEN',createdBy:'owner'};
 await expect(commit([write('disputes/op-dispute',dispute,['createdAt'])]),200,'create source dispute');
 await expect(commit([write('disputes/op-foreign',{...dispute,createdBy:'other'},['createdAt'])],'other'),403,'foreign source dispute denied');
 await expect(commit([write('disputes/op-dispute',{status:'UNDER_REVIEW',resolution:'Checking scale',reviewedBy:'owner'},['reviewedAt'],true)]),200,'review dispute');
 await expect(commit([write('disputes/op-dispute',{status:'RESOLVED',resolution:'Scale record verified',reviewedBy:'owner'},['reviewedAt'],true)]),200,'resolve dispute');
 await expect(commit([write('disputes/op-dispute',{status:'OPEN',resolution:'Reopen',reviewedBy:'owner'},['reviewedAt'],true)]),403,'closed dispute cannot reopen');
 for(const [path,uid,status,label] of [['batches/op-good','other',403,'foreign batch read'],['disputes/op-dispute','other',403,'foreign dispute read'],['batches/op-good',null,403,'anonymous batch read'],['batches/op-good','owner',200,'owner batch read']]){
   await expect(fetch(`${base}/${path}`,{headers:uid?{Authorization:`Bearer ${token(uid)}`}:{}}),status,label);
 }
 await expect(fetch(`${base}/collections/op-0`,{method:'DELETE',headers:{Authorization:`Bearer ${token('owner')}`}}),403,'batched source cannot be deleted');
})().catch(e=>{console.error(e);process.exitCode=1;});
