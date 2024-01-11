import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import model "model";
import ns "namespace";
import us "userspace";
import Namespace "namespace";
// a canister per user / organization. actor declear operations api of current user
actor{

    type UserInfo = model.UserInfo;
    type UserActor = us.UserSpace;
    private stable var users : List.List<Principal> = List.nil();

    public shared({caller}) func sign(user: UserInfo): async Principal{
        let userActor = await us.UserSpace(caller, user.name, user.avatar, user.about, user.background);
        let id = Principal.fromActor(userActor);
        users := List.push(id, users);
        id;
    }

};
