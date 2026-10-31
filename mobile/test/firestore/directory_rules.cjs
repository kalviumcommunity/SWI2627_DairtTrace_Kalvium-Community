const assert = require('node:assert/strict');
const base = 'http://127.0.0.1:18080/v1/projects/demo-dairytrace/databases/(default)/documents';
function token(uid) {
  const now = Math.floor(Date.now() / 1000);
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${encode({alg:'none',typ:'JWT'})}.${encode({
    iss:'https://securetoken.google.com/demo-dairytrace',aud:'demo-dairytrace',
    sub:uid,user_id:uid,iat:now,exp:now+3600,auth_time:now,
    firebase:{sign_in_provider:'custom',identities:{}}
  })}.`;
}
const field = value => ({stringValue:value});
async function call(path, method, body, auth) {
  return fetch(`${base}${path}`, {method, headers:{'Content-Type':'application/json',
    ...(auth ? {Authorization:`Bearer ${auth}`} : {})}, body:body ? JSON.stringify(body) : undefined});
}
async function create(path, values, uid) {
  const fields = Object.fromEntries(Object.entries(values).map(([key,value])=>[key,field(value)]));
  return call(':commit','POST',{writes:[{
    update:{name:`projects/demo-dairytrace/databases/(default)/documents/${path}`,fields},
    currentDocument:{exists:false},
    updateTransforms:[{fieldPath:'createdAt',setToServerValue:'REQUEST_TIME'}]
  }]}, token(uid));
}
async function expect(response, status, label) {
  const body = await response.text();
  assert.equal(response.status,status,`${label}: ${body}`);
  console.log(`PASS: ${label}`);
}
(async()=>{
  const center = {name:'Rampur Centre',village:'Rampur',status:'ACTIVE',createdBy:'operator-a'};
  await expect(await create('collectionCenters/center-a',center,'operator-a'),200,'owner can register centre');
  await expect(await create('collectionCenters/forged',center,'operator-b'),403,'cannot forge centre owner');
  const farmer = {name:'Rajesh Kumar',village:'Rampur',phone:'9876543210',centerId:'center-a',status:'ACTIVE',createdBy:'operator-a'};
  await expect(await create('farmers/farmer-a',farmer,'operator-a'),200,'owner can register farmer');
  await expect(await create('farmers/orphan',{...farmer,centerId:'missing'},'operator-a'),403,'orphan farmer denied');
  await expect(await create('farmers/cross-owner',{...farmer,createdBy:'operator-b'},'operator-b'),403,'foreign centre denied');
  await expect(await create('farmers/invalid-phone',{...farmer,phone:'abc'},'operator-a'),403,'invalid contact denied');
  await expect(await call('/farmers/farmer-a','GET',null,token('operator-a')),200,'owner read allowed');
  await expect(await call('/farmers/farmer-a','GET',null,token('operator-b')),403,'other operator read denied');
  await expect(await call('/farmers/farmer-a','GET'),403,'unauthenticated read denied');
  await expect(await call('/farmers/farmer-a','DELETE',null,token('operator-a')),403,'unaudited deletion denied');
})().catch(error=>{console.error(error);process.exitCode=1;});
