import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Bool "mo:base/Bool";
import Trie "mo:base/Trie";
import model "model";
import ns "namespace";
import us "userspace";
import Namespace "namespace";
// a canister per user / organization. actor declear operations api of current user
actor{

    type UserInfo = model.UserInfo;
    type UserActor = us.UserSpace;
    type Resp<T> = model.Resp<T>;
    type Trie<K, V> = Trie.Trie<K, V>;
    type Key<K> = Trie.Key<K>;
    private stable var cyclesPerToken: Nat = 200_000_000_000; // 0.2t cycles for each token canister
    private stable var users : List.List<Principal> = List.nil();
    private stable var userCanisterMap : Trie<Principal, Principal> = Trie.empty();

    public shared({caller}) func sign(name: Text, avatar: Text, about: Text): async Bool{
        assert(not containtUserCanister(caller));
        Cycles.add(cyclesPerToken);
        users := List.push(caller, users);
        let userActor = await us.UserSpace(List.size(users), caller, name, avatar, about);
        let userActorId = Principal.fromActor(userActor);
        putUserCanisterId(caller, userActorId);
        true;
    };

    public shared({caller}) func getUserInfo(): async Resp<UserInfo>{
        switch(getUserActorId caller){
            case(null){
                return {code=404;data={index=0;id=caller;name="";avatar="";about="";ctime=Time.now()}};
            };
            case(?id){
                let userActor: UserActor = actor(Principal.toText(id));
                return {code=200;data=await userActor.getUserInfo()};
            };
        };
    };


    func keyOfPrincipal(id: Principal) : Key<Principal> {
        { 
            hash = Principal.hash id;
            key = id; 
        } 
    };
    func putUserCanisterId(id: Principal, userActorId: Principal){
        userCanisterMap := Trie.put(userCanisterMap, keyOfPrincipal id, Principal.equal, userActorId).0;
    };

    func getUserActorId(id: Principal): ?Principal{
        Trie.get(userCanisterMap, keyOfPrincipal id, Principal.equal)
    };

    func containtUserCanister(id:Principal): Bool{
        switch(getUserActorId id){
            case(null){
                return false;
            };
            case(?time){
                return true;
            };
        };
    };

};
