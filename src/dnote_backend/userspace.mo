import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import model "model";
import ns "namespace";

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
    private stable var ownerNs: List.List<NamespaceModel> = List.nil();
    private stable var follows: List.List<Principal> = List.nil();
    // just subscribe namespace 
    private stable var subscribes: List.List<Principal> = List.nil();

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
        let namespaceModel: NamespaceModel = {id=nsId; name=name};
        ownerNs := List.push(namespaceModel, ownerNs);
    };

    public shared({caller}) func follow(id: Principal): async(){
        follows := List.push(id, follows);
    };

    public shared({caller}) func followSize(): async Nat {
        List.size(follows);
    };

    public shared({caller}) func subscribe(id: Principal): async (){
        subscribes := List.push(id, subscribes);
    };

} 