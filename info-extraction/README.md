To run the server:

`ruby server.rb -p 3000` 

The service will be available on port 3000. 

Example cURL call:

```
curl -X POST \
  http://localhost:3000/watson \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 07940dd1-499e-4716-9a78-a356b9287dd1' \
  -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' \
  -F 'text=GOSH so whats been going on well you KNOW we started this medication the different medication A COUPLE OF 
**** so whats been going on well you KNEW we started this medication the different medication * ****** **
WEEKS AGO THE TAXOL yeah yeah well it **** KINDA sucks okay so youve been having some side effects from 
***** *** *** ***** yeah yeah well it KIND OF    sucks okay so youve been having some side effects from 
taking that medication whats whats been going on specifically yeah so i dont **** whether its this or **** 
taking that medication whats whats been going on specifically yeah so i dont KNOW whether its this or JUST 
something else is happening but **** im feeling like ive just got aches all over IN my shoulders IN  my arms 
something else is happening but LIKE im feeling like ive just got aches all over ** my shoulders AND my arms 
and um and something funnys going on with my fingers like i think theres some of them are numb sometimes it 
and um and something funnys going on with my fingers like i think theres some of them are numb sometimes it 
tingles i cant tell whats going on feels like my whole **** BODYS going to sleep on me ** feels like my 
tingles i cant tell whats going on feels like my whole BODY IS    going to sleep on me IT feels like my 
fingers AND my feet keep wanting to go to sleep on me oh dear okay so um something to note is oftentimes the 
fingers ARE my feet keep wanting to go to sleep on me oh dear okay so um something to note is oftentimes the 
side effects um or the toxicity associated with medications like herceptin or taxol UM are the myalgias or 
side effects um or the toxicity associated with medications like herceptin or taxol ** are the myalgias or 
the muscle aches um and THAT tingling or peripheral sensory neuropathy UM as we call it uh IS  oftentimes 
the muscle aches um and AT   tingling or peripheral sensory neuropathy ** as we call it uh ITS oftentimes 
'
```