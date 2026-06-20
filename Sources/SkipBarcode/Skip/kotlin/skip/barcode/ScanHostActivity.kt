package skip.barcode

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts

/**
 * Transparent trampoline activity that launches [MLKitScanActivity] for result,
 * stores the result in a static slot, then finishes. Skip Swift code launches it
 * via [launch] and polls [hasResult]/[getBarcode].
 */
class ScanHostActivity : ComponentActivity() {

    companion object {
        private const val TAG = "ScanHostActivity"

        @Volatile private var lastResultCode: Int? = null
        @Volatile private var lastBarcode: String? = null
        @Volatile private var resultReady = false

        @JvmStatic
        fun launch(context: Context) {
            lastResultCode = null
            lastBarcode = null
            resultReady = false
            val intent = Intent(context, ScanHostActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }

        @JvmStatic fun hasResult(): Boolean = resultReady
        @JvmStatic fun getResultCode(): Int = lastResultCode ?: Activity.RESULT_CANCELED
        @JvmStatic fun getBarcode(): String? = lastBarcode
        @JvmStatic fun clearResult() {
            lastResultCode = null
            lastBarcode = null
            resultReady = false
        }

        private fun setResult(resultCode: Int, barcode: String?) {
            lastResultCode = resultCode
            lastBarcode = barcode
            resultReady = true
        }
    }

    private val launcher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        val barcode = if (result.resultCode == Activity.RESULT_OK) {
            result.data?.getStringExtra(MLKitScanActivity.EXTRA_BARCODE)
        } else {
            null
        }
        Companion.setResult(result.resultCode, barcode)
        finish()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            launcher.launch(Intent(this, MLKitScanActivity::class.java))
        } catch (e: Exception) {
            Log.e(TAG, "Error launching MLKitScanActivity", e)
            Companion.setResult(Activity.RESULT_CANCELED, null)
            finish()
        }
    }
}
