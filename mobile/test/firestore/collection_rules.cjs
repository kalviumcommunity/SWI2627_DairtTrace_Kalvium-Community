const assert = require('node:assert/strict');
const base = 'http://127.0.0.1:18080/v1/projects/demo-dairytrace/databases/(default)/documents';
function token(uid) {
  const now = Math.floor(Date.now()/1000);
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${encode({alg:'none',typ:'JWT'})}.${encode({iss:'https://securetoken.google.com/demo-dairytrace',aud:'demo-dairytrace',sub:uid,user_id:uid,iat:now,exp:now+3600,auth_time:now,firebase:{sign_in_provider:'custom',identities:{}}})}.`;
}
async function call(path, method, body, uid) {
  return fetch(`${base}${path}`, {method,headers:{'Content-Type':'application/json',...(uid ? {Authorization:`Bearer ${token(uid)}`} : {})},body:body ? JSON.stringify(body):undefined});
}
const name = id => `projects/demo-dairytrace/databases/(default)/documents/collections/${id}`;
const encode = values => Object.fromEntries(Object.entries(values).map(([k,v])=>[k,typeof v === 'number' ? {doubleValue:v} : {stringValue:v}]));
async function create(id, quality, uid='owner') {
  return call(':commit','POST',{writes:[{update:{name:name(id),fields:encode({farmerName:'Farmer Name',quantityLitres:12,createdBy:'owner',...quality})},currentDocument:{exists:false},updateTransforms:['collectionDate','createdAt'].map(fieldPath=>({fieldPath,setToServerValue:'REQUEST_TIME'}))}]},uid);
}
async function expect(response, status, label) {
  assert.equal(response.status,status,`${label}: ${await response.text()}`);
  console.log(`PASS: ${label}`);
}
(async()=>{
  const good = {fat:4,snf:8.5,temperature:6,qualityStatus:'ACCEPTED'};
  await expect(await create('accepted',good),200,'accepted readings saved');
  await expect(await create('alert',{...good,fat:2,qualityStatus:'ALERT'}),200,'alert readings saved');
  await expect(await create('boundary',{fat:3,snf:8,temperature:10,qualityStatus:'ACCEPTED'}),200,'inclusive thresholds');
  await expect(await create('legacy',{}),200,'legacy writes remain supported');
  await expect(await create('forged',{...good,fat:2}),403,'incorrect accepted status denied');
  await expect(await create('forged-alert',{...good,qualityStatus:'ALERT'}),403,'incorrect alert status denied');
  await expect(await create('invalid',{...good,snf:101}),403,'invalid percentage denied');
  await expect(await create('negative',{...good,temperature:-1}),403,'negative temperature denied');
  await expect(await create('partial',{fat:4}),403,'partial readings denied');
  await expect(await create('foreign',good,'other'),403,'forged ownership denied');
  await expect(await create('anonymous',good,null),403,'unauthenticated write denied');
  await expect(await call('/collections/accepted','GET',null,'owner'),200,'owner can read');
  await expect(await call('/collections/accepted','GET',null,'other'),403,'other user cannot read');
  await expect(await call('/collections/accepted','DELETE',null,'other'),403,'other user cannot delete');
  await expect(await call('/collections/accepted','DELETE',null,'owner'),200,'owner can delete');
})().catch(error=>{console.error(error);process.exitCode=1;});
