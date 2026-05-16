import kotlinx.cinterop.ExperimentalForeignApi
import swiftPMImport.kmp.swift.native.KeychainService

@OptIn(ExperimentalForeignApi::class)
fun keychain() {
    val keychain = KeychainService()
    val result = keychain.listAllItemsAsResult()
    for (i in 0 until result.count()) {
        val item = result.getItemAt(i)
        item?.let {
            println("Keychain - account: ${it.account()}, service: ${it.service()}, label: ${it.label()}")

//            if (it.account() == "Terezka_5G") {
//                val token = keychain.getTokenFor(it)
//                println("Token: ${token ?: "none"}")
//            }
            // Get token , for token i need permission

        }

    }
}
