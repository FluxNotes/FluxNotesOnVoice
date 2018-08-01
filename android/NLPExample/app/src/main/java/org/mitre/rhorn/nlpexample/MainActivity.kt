package org.mitre.rhorn.nlpexample

import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.EditText
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley

const val EXTRA_MESSAGE = "org.mitre.rhorn.nlpexample.MESSAGE"
const val BOUNDARY = "BHH2P347U89HFSDOIFJQP2"
const val MULTIPART_FORMDATA = "multipart/form-data;boundary=$BOUNDARY"
const val SAMPLE_TRANSCRIPTION = "GOSH so whats been going on well you KNOW we started this medication the different medication A COUPLE OF \n" +
        "**** so whats been going on well you KNEW we started this medication the different medication * ****** **\n" +
        "WEEKS AGO THE TAXOL yeah yeah well it **** KINDA sucks okay so youve been having some side effects from \n" +
        "***** *** *** ***** yeah yeah well it KIND OF    sucks okay so youve been having some side effects from \n" +
        "taking that medication whats whats been going on specifically yeah so i dont **** whether its this or **** \n" +
        "taking that medication whats whats been going on specifically yeah so i dont KNOW whether its this or JUST \n" +
        "something else is happening but **** im feeling like ive just got aches all over IN my shoulders IN  my arms \n" +
        "something else is happening but LIKE im feeling like ive just got aches all over ** my shoulders AND my arms \n" +
        "and um and something funnys going on with my fingers like i think theres some of them are numb sometimes it \n" +
        "and um and something funnys going on with my fingers like i think theres some of them are numb sometimes it \n" +
        "tingles i cant tell whats going on feels like my whole **** BODYS going to sleep on me ** feels like my \n" +
        "tingles i cant tell whats going on feels like my whole BODY IS    going to sleep on me IT feels like my \n" +
        "fingers AND my feet keep wanting to go to sleep on me oh dear okay so um something to note is oftentimes the \n" +
        "fingers ARE my feet keep wanting to go to sleep on me oh dear okay so um something to note is oftentimes the \n" +
        "side effects um or the toxicity associated with medications like herceptin or taxol UM are the myalgias or \n" +
        "side effects um or the toxicity associated with medications like herceptin or taxol ** are the myalgias or \n" +
        "the muscle aches um and THAT tingling or peripheral sensory neuropathy UM as we call it uh IS  oftentimes \n" +
        "the muscle aches um and AT   tingling or peripheral sensory neuropathy ** as we call it uh ITS oftentimes"

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    fun sendMessage(view: View) {
        Log.i("MAIN", "Doing request")
        val editText = findViewById<EditText>(R.id.editText)
        val host = editText.text.toString()
        val url = "http://$host/watson"
        Log.i("MAIN", url)
        val queue = Volley.newRequestQueue(this)

        val request = object : StringRequest(Request.Method.POST, url,
                Response.Listener<String> { response ->
                    Log.i("MAIN", "SUCCESS")
                    Log.i("MAIN", response)
                    val intent = Intent(this, DisplayMessageActivity::class.java).apply {
                        putExtra(EXTRA_MESSAGE, response.substring(0, 500))
                    }
                    startActivity(intent)
                },
                Response.ErrorListener { error ->
                    Log.e("MAIN", error.toString())
                }
        ) {

            override fun getBodyContentType(): String {
                return MULTIPART_FORMDATA
            }

            override fun getBody(): ByteArray {
                val params = HashMap<String, String>()
                params.put("text", SAMPLE_TRANSCRIPTION)
                val map: List<String> = params.map {
                    (key, value) -> "--$BOUNDARY\r\nContent-Disposition: form-data; name=\"$key\"\r\n\r\n$value\r\n"
                }

                val ret = "${map.joinToString("")}\r\n--$BOUNDARY--\r\n"
                return ret.toByteArray()
            }

            override fun getHeaders(): Map<String, String> {
                val headers = HashMap<String, String>()
                headers.put("Content-Type", MULTIPART_FORMDATA)
                headers.put("Cache-Control", "no-cache")

                return headers
            }
        }
        Log.i("MAIN", request.headers.toString())
        Log.i("MAIN", String(request.body))
        queue.add(request)

    }
}
