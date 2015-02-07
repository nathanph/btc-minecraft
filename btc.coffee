###
# @author   Nathan Hernandez <email@nathanph.com>
# @version  0.1
# @since    2015-02-07
###
bitcore = require('bitcore')
qrcode  = require('qrcode')

###
# Generates a public-private bitcoin key-pair and returns an address.
#
# The public-private bitcoin key-pair will be stored in the database.
#
# @return An address to be sent to the user.
###
generateAddress = () ->
    privateKey = bitcore.PrivateKey()
    publicKey = privateKey.toPublicKey()

    privateKeyString = privateKey.toWIF()
    # TODO: Store privateKeyString in database here.

    publicKeyString = publicKey.toString()
    # TODO: Store publicKeyString in database here.

    address = publicKey.toAddress()

    return address.toString()

###
# Generates a URI transaction request.
#
# This URI transaction request can be used by the client to quickly launch the default bitcoin wallet and make a transacion.
#
# @param address The address for bitcoin to be sent to.
# @param satoshis The amount of bitcoin requested to be sent in satoshis.
# @param message A message to be sent along with the transaction request.
# @return A URI transaction request to be handled by a bitcoin wallet.
###
generateUriRequest = (address, satoshis, message) ->
    uri = new bitcore.URI({
        "address":  address,
        "amount":   satoshis,
        "message":  message,
    })
    return uri.toString()

###
# Generates a QR code.
#
# This QR code is returned as a mime image/png data url.
#
# @param address A bitcoin address to convert into a QR code.
# @param callback A callback function receiving error and dataURL.
###
generateQrCode = (address, callback) ->
    qrcode.toDataURL(address, "max",
    (error, dataURL) ->
        callback(error, dataURL))



# TODO: Test code; delete or comment everything after this.
address = generateAddress()
uriRequest = generateUriRequest(address, 5000)
qrCodeUrl = ""
generateQrCode(address,
(error, dataURL) ->
    qrCodeUrl = dataURL
    console.log(qrCodeUrl))

console.log(address)
console.log(uriRequest)
