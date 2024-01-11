import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import model "model";
import ns "namespace";
import Namespace "namespace";

// 用户Admin-Canister： 用户信息管理、NS管理、Cycles管理、NS订阅管理、粉丝管理、关注管理
shared({caller}) actor class UserSpace(
    _owner: Principal,
    _name: Text,
    _avatar: Text,
    _about: Text,
    _background: Text,
) = this{

    type UserInfo = model.UserInfo;
    type NamespaceModel = model.NamespaceModel;
    type OpenType = model.OpenType;
    type NamespaceActor = ns.NamespaceActor;

    private stable var owner : Principal = _owner;
    private stable var name : Text = _name;
    private stable var avatar : Text = _avatar;
    private stable var about : Text = _about;
    private stable var background : Text = _background;
    private stable var ctime : Time.Time = Time.now();

    // personal workspace info
    private stable var ownerNs: List.List<Principal> = List.nil();
    private stable var follows: List.List<Principal> = List.nil();
    // just subscribe namespace 
    private stable var subscribes: List.List<NamespaceModel> = List.nil();

    public shared({caller}) func getUserInfo(): async UserInfo{
        {
            id=owner;
            name=name;
            avatar=avatar;
            about=about;
            background=background;
            ctime=ctime;
        }
    };

    public shared({caller}) func updateUserInfo(user: UserInfo):async (){
        assert(caller == owner);
        name := user.name;
        avatar := user.avatar;
        about := user.about;
        background := user.background;
    };

    public shared({caller}) func createNamespace(name: Text, desc: Text, openType: OpenType): async(){
        assert(caller == owner);
        let namespace = await ns.NamespaceActor(caller, name, "", desc, openType);
        let nsId = Principal.fromActor(namespace);
        ownerNs := List.push(nsId, ownerNs);
    };

    public shared({caller}) func updateNamespace(nsId: Principal, name: Text, desc: Text, openType: OpenType): async(){
        assert(caller == owner);
        let namespace: NamespaceActor = actor(Principal.toText(nsId));
        await namespace.updateInfo(name,desc,openType);
    };

    public shared({caller}) func follow(id: Principal): async(){
        assert(caller == owner);
        follows := List.push(id, follows);
    };

    public shared({caller}) func followSize(): async Nat {
        assert(caller == owner);
        List.size(follows);
    };

    public shared({caller}) func unFollow(id: Principal): async(){
        assert(caller == owner);
        var newFollows:List.List<Principal> = List.nil();
        for(follow in List.toIter<Principal>(follows)){
            if(id != follow){
                newFollows := List.push(follow, newFollows);
            };
        };
        follows := newFollows;
    };

    public shared({caller}) func subscribe(id: Principal): async (){
        assert(caller == owner);
        // make sure target is namespace canister
        let namespace: NamespaceActor = actor(Principal.toText(id));
        let model = await namespace.addSubscriber();
        subscribes := List.push(model, subscribes);
    };

    // 懒加载，前端检测到namespace更新时更新本地namespaceinfo
    public shared({caller}) func listSubscribe(): async [NamespaceModel]{
        List.toArray(subscribes);
    };

    public shared({caller}) func unSubscribe(id: Principal): async(){
        assert(caller == owner);
        var newSub :List.List<NamespaceModel> = List.nil();
        for(model in List.toIter<NamespaceModel>(subscribes)){
            if(id != model.id){
                newSub := List.push(model, newSub);
            };
        };
        subscribes := newSub;
    };

    

} 