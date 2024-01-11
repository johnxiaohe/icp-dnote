import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Trie "mo:base/Trie";
import Bool "mo:base/Bool";
import model "model";
import ns "namespace";

// @deprecated
actor{

    type OpenType = model.OpenType;
    type UserInfo = model.UserInfo;
    type NamespaceModel = model.NamespaceModel;

    type Trie<K, V> = Trie.Trie<K, V>;
    type Key<K> = Trie.Key<K>;

    // private stable var users: List.List<UserInfo> = List.nil();
    private stable var userInfos:Trie<Principal, UserInfo> = Trie.empty();
    private stable var namespaces:Trie<Principal, NamespaceModel> = Trie.empty();

    public shared({caller}) func signin(name: Text, about: Text, avatar: Text, bg: Text): async(){
        let user: UserInfo = {
            id=caller;
            name=name;
            avatar=avatar;
            about=about;
            background=bg;
            ctime=Time.now();
        };
        // users := List.push(user, users);
        put(caller, user);
    };

    public shared({caller}) func updateInfo(name: Text, about: Text, avatar: Text, bg: Text): async Text{
        switch (get(caller)) {
            case null{
                return "not matched";
            };
            case (?user){
                let n_user = {
                    id=caller;
                    name=name;
                    avatar=avatar;
                    about=about;
                    background=bg;
                    ctime=user.ctime;
                };
                put(caller, n_user);
                return "success";
            };
        };
    };

    public shared({caller}) func createNamespace(name: Text, desc: Text, openType: OpenType): async(){
        assert(get(caller) != null);

        let namespace = await ns.NamespaceActor(caller, name, "", desc, openType);
        let nsId = Principal.fromActor(namespace);
        // let namespaceModel: NamespaceModel = {id=nsId; name=name};
        // namespaces := Trie.put(namespaces, key nsId, Principal.equal, namespaceModel).0;
    };







    // private tool func cover principal --  Key<Principal>
    func key(id: Principal) : Key<Principal> {
        { 
            hash = Principal.hash id;
            key = id; 
        } 
    };

    func put(id: Principal, user: UserInfo){
        userInfos := Trie.put(userInfos, key id, Principal.equal, user).0;
    };

    func get(id: Principal): ?UserInfo{
        Trie.get(userInfos, key id, Principal.equal);
    };

}