


endpoint        | GET                     | PUT                 | POST                  | DELETE
--------------- | ----------------------- | ------------------- | --------------------- | ----------------
subscribe       | subscribe methods       | confirm account     | create account        | ...
account         | get account details     | update account      | login account         | remove account
feed            | get todays feed list    | ...                 | subscribe             | ...
feed/<id>       | display feed            | mark read           | ...                   | unsubscribe
feed/archive    | collection unread items | ...                 | mark item unread      | clear all unread
feed/starred    | collection saved items  | remove starred item | create new starred    | clear collection
item/<id>       | show full item          | ...                 | ...                   | ...
