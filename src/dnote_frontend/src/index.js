import { createActor,dnote_backend } from "../../declarations/dnote_backend";
import { createActor as cUserActor} from "../../declarations/dnote_user";
import {AuthClient} from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
// import { createUserActor } from "./user";

let mActor = dnote_backend;
let uActor;

let userInfo = undefined;
let identity;

const indexElm = document.getElementById("index");
const loginButton = document.getElementById("login");
const username = document.getElementById("username");
const namespaceButton = document.getElementById("namespaces");
const s_submit = document.getElementById("s_submit");
const signup_form = document.getElementById("signup");
signup_form.style.display = 'none';

async function index(){
  const idx = document.getElementById("idx");
  const nsp = document.getElementById("nsp");
  const ats = document.getElementById("ats");
  idx.style.display = 'block';
  nsp.style.display = 'none';
  ats.style.display = 'none';
}

async function login(e) {
  e.preventDefault();
  let authClient = await AuthClient.create();
  if(! await authClient.isAuthenticated()){
    await new Promise((resolve) => {
      authClient.login({
        identityProvider: process.env.II_URL,
        onSuccess: resolve,
      })
    });
  }
  const identity = authClient.getIdentity();
  const agent = new HttpAgent({identity});
  mActor = createActor(process.env.DNOTE_BACKEND_CANISTER_ID, {agent});

  let userInfoResp = await mActor.getUserInfo();
  console.log(userInfoResp);
  if (userInfoResp.code == 404){
    // 用户尚未注册，弹窗提示注册信息。
    alert("请先提交基础信息");
    signup_form.style.display = '';
  }else if(userInfoResp.code == 200){
    userInfo = userInfoResp.data;
    console.log(userInfo);
    uActor = cUserActor(userInfo.id, {agent});
    // 登陆按钮隐藏，显示个人头像按钮
    loginButton.innerText = "Logout";
    username.innerText = userInfo.name;
    const welcome = document.getElementById("welcome");
    welcome.innerText = "Welcome " + userInfo.name;
  }
};

async function namespaces(){
  if(userInfo == undefined){
    alert("pls connect wallet");
    return;
  }
  const idx = document.getElementById("idx");
  const nsp = document.getElementById("nsp");
  const ats = document.getElementById("ats");
  idx.style.display = 'none';
  nsp.style.display = 'flex';
  ats.style.display = 'none';
  const nsp_u = document.getElementById("nsp_u");
  nsp_u.innerHTML = ''
  let namespaces = await uActor.namespaces();
  console.log(namespaces);
  for(let ns of namespaces){
    console.log(ns);
    let n_li = document.createElement("li");
    n_li.id=ns.id;
    n_li.innerText=ns.name;
    n_li.onclick = () => ns_list(ns.id, ns.name);
    nsp_u.appendChild(n_li);
  }
  let n_li = document.createElement("li");
  n_li.innerText='+';
  n_li.id = "n_ns";
  n_li.onclick = addNs;
  nsp_u.appendChild(n_li);
}

async function submit(){
  const n_username = document.getElementById("n_username");
  let username = n_username.value;
  if(username == ""){
    alert("pls enter username");
    return;
  }
  await mActor.sign(username, "", "a man");
  signup_form.style.display = 'none';
  let userInfoResp = await mActor.getUserInfo();
  console.log(userInfoResp);
  userInfo = userInfoResp.data;
  console.log(userInfo);
  uActor = createUserActor(identity, userInfo.id);
  // 登陆按钮隐藏，显示个人头像按钮
  loginButton.innerText = "Logout";
  username.innerText = userInfo.name;
  const welcome = document.getElementById("welcome");
  welcome.innerText = "Welcome " + userInfo.name;
}

async function addNs(){
  let n_li = document.getElementById("n_ns");
  n_li.onclick = null;
  // 录入名称、简介。提交创建。重载nsp页面
  n_li.innerHTML = "";
  n_li.innerHTML = "<div><lable>ns-name:</lable><input id=\"ns_name\" type=\"text\"/><lable>desc:</lable><input id=\"ns_desc\" type=\"text\"/><button id=\"ns_save\">save</button></div>"
  let ns_save = document.getElementById("ns_save");
  ns_save.onclick = createNs;
}

async function createNs(){
  let ns_name = document.getElementById("ns_name");
  let ns_desc = document.getElementById("ns_desc");
  await uActor.createNamespace(ns_name.value, ns_desc.value, {"Public": null} );
  alert("create success!");
  await namespaces();
}

// 指定命名空间的文章列表
async function ns_list(id,name){
  let c_ns = document.getElementById("c_ns");
  c_ns.innerText = name;
  c_ns.onclick = () => ns_list(id,name);

  let ats = document.getElementById("ats");
  ats.style.display='grid';
  const idx = document.getElementById("idx");
  idx.style.display = 'none';
  const nsp = document.getElementById("nsp");
  nsp.style.display = 'none';

  const t_tt = document.getElementById("t_tt");
  t_tt.innerText = "";
  const c_ctx = document.getElementById("c_ctx");
  c_ctx.innerText = "pls click title from left side for view content";
  const up_tt = document.getElementById("up_tt");
  up_tt.style.display = "none";

  const aul = document.getElementById("aul");
  aul.innerHTML = "";
  let notes = await uActor.articals(id,0);
  console.log(notes);
  for(let note of notes){
    let noteLi = document.createElement("li");
    noteLi.innerText = note.title;
    noteLi.id = note.id;
    noteLi.onclick = () => artical(id, note.id, note.title, note.content);
    aul.appendChild(noteLi);
  }
  let addNoteLi = document.createElement("li");
  addNoteLi.id = "addNoteLi";
  addNoteLi.innerHTML = "<h3>+</h3>"
  addNoteLi.onclick = () => c_artical(id,name);
  aul.appendChild(addNoteLi);
}

// 创建该命名空间下文章
async function c_artical(id, name){
  let addNoteLi = document.getElementById("addNoteLi");
  addNoteLi.onclick = null;
  addNoteLi.innerHTML = "<input id=\"a_title\" type=\"text\" /><button id=\"s_note\">save</button>"
  let s_note = document.getElementById("s_note");
  s_note.onclick = async () => {
    let title = document.getElementById("a_title").value;
    await uActor.createArtical(id,title,"",0);
    alert("添加文章成功");
    ns_list(id,name);
  }
}

// 获取文章信息，添加到ctt中
async function artical(ns_id, id, title, content){
  const t_tt = document.getElementById("t_tt");
  t_tt.innerText = title;
  const c_ctx = document.getElementById("c_ctx");
  c_ctx.innerText = content;
  c_ctx.style.display="block";
  const up_tt = document.getElementById("up_tt");
  up_tt.style.display = "block";
  const u_ctx = document.getElementById("u_ctx");
  u_ctx.style.display = "none";
  up_tt.onclick = async () => {
    if (up_tt.innerText == "save"){
      await uActor.updateArtical(ns_id, id, title, u_ctx.value);
      c_ctx.innerText = u_ctx.value;
      u_ctx.style.display = 'none';
      c_ctx.style.display = 'block';
      up_tt.innerText = "update";
      return;
    }
    if(up_tt.innerText == "update"){
      up_tt.innerText = "save";
      c_ctx.style.display='none';
      u_ctx.style.display = "block";
      u_ctx.value = content;
      return;
    }
  };
}

indexElm.onclick = index;
loginButton.onclick = login;
namespaceButton.onclick = namespaces;
s_submit.onclick = submit;