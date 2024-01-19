import { createActor } from "../../declarations/dnote_user";
import {AuthClient} from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

// 用户使用自己的身份访问自己的canister
// 用户用自己的canister做代理身份，访问不同的namespace。
async function userActor(identity, cid){
    const agent = new HttpAgent({identity});
    const uActor = createActor(cid, {agent});
    return uActor;
}

export const createUserActor = userActor;


