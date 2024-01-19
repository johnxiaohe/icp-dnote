# Dnote
Focus on document and knowledge record sharing tools used by individuals and organizations
https://github.com/ICPHackathon/ICP-Hackathon-2023/issues/16

Modules:  
Diary management  
Namespace management  
Subscription management(focus namespace, subscription:free/payable)  
Level management  
Access management(write access)  
Note management  
Portal  

Namespace Scope:  
personal、organizational  

Visibility type  
Diary: private(encrypt?)  
Namespace: public\private  
Note: public\public&payable\subscription\private  

Searchable  
public\payable\subscription : searchable  
private : not searchable  

Advantage  
Dnote has no risk of going offline and will not cause application unavailability problems caused by component downtime. 
Public price and no migaration hassles, Data not lost.
The cost is only related to usage, data size, and usage time. There will be no additional charges or abnormal cost fluctuations due to company size or discounts.

dfx deploy dnote_user --argument '(0,principal "ogqo3-cdg7w-caty4-gmgqe-y6bzu-3p2wb-6q3co-i7ww4-llbju-bgida-jqe","init","init","init")'