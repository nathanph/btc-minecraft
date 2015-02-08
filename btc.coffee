###
# @author   Nathan Hernandez <email@nathanph.com>
# @version  0.1
# @since    2015-02-07
###
bitcore = require('bitcore')
qrcode  = require('qrcode')
request = require('request')
async   = require('async')
Insight = require('bitcore-explorers').Insight

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

###
# Consolidates bitcoin from several addresses into one.
#
# This is used to send the pool of bitcoin to the winner.
#
# @param privateKeys An array of private keys in the pool.
# @param outputAddress An address to send bitcoin to.
# @param changeAddress An address to send change to.
###
consolidatePool = (privateKeyStrings, outputAddress, changeAddress) ->
    privateKeys = []
    for privateKeyString in privateKeyStrings
        privateKeys.push(bitcore.PrivateKey.fromWIF(privateKeyString))

    publicKeys = []
    for privateKey in privateKeys
        publicKeys.push(privateKey.toPublicKey())

    addresses = []
    for publicKey in publicKeys
        addresses.push(publicKey.toAddress())

    addressStrings = []
    for address in addresses
        addressStrings.push(address.toString())

    insight = new Insight()
    insight.getUnspentUtxos(addressStrings,
    (err, utxos) ->
        if err
            console.log("Error: "+err)
        else
            console.log(utxos)

            transaction = new bitcore.Transaction()
            transaction
            .from(utxos)
            .to(outputAddress,transaction._inputAmount)
            .change(changeAddress)
            .sign(privateKeyStrings)

            console.log(transaction)

            insight.broadcast(transaction,
            (GetUnspentUtxosCallback) ->
                console.log(GetUnspentUtxosCallback)
            )
    )

pendingUserAddresses = () ->
    request("http://bitmine.herokuapp.com/api/pending",
    (error, response, json) ->
        if !error and response.statusCode == 200
            JSON.parse(json).forEach (jsonString) ->
                address = bitcore.PublicKey.fromString(jsonString.public).toAddress()
                console.log("https://blockchain.info/address/"+address.toString()+"?format=json")
                request('https://blockchain.info/address/'+address.toString()+'?format=json',
                (error, response, transaction) ->
                    console.log(transaction)
                    if !error and response.statusCode == 200
                        if JSON.parse(transaction)
                            if(JSON.parse(transaction).total_received > 0)
                                console.log(transaction.total_sent)
                                console.log("TX exists.")
                                request.post('http://bitmine.herokuapp.com/api/addresses/'+jsonString.id+'/complete',
                                (error, response, json) ->
                                    console.log("Address with ID "+jsonString.id+" has paid.")
                                )
                        else
                            console.log("Could not find TX.")
                )
    )


# TODO: Test code delete or comment everything after this.
address = generateAddress()
#uriRequest = generateUriRequest(address, 5000)
#qrCodeUrl = ""
#generateQrCode(address,
#(error, dataURL) ->
#    qrCodeUrl = dataURL
#    console.log(qrCodeUrl))
#
#console.log(address)
#console.log(uriRequest)

privateKeys = []
#for i in [1..5]
#    privateKeys.push(bitcore.PrivateKey().toWIF())

#privateKeys = ["5KDETDUafepKBA4x9NKnv6XXzFUaXm1ms6GHNeNNc57fTFcfDJm"]

privateKeys.push("5HuVrZMSfbiJotNvtrfgMjPhi1y3NxbbCQQPQnBG6PKJpdEbzT8")
privateKeys.push("5J4at5zeNisq6GPmF9kuFmJeght16xJ4yLTQTrooM1ZYHSmq67i")
outputAddress = "1BPf9aLo5rKQe5kaUgtHk9jbQ7Nm8BRZrB"
changeAddress = "1MWyHEGdHMgLozTsyJrwdsSASUWDi4uQdn"

#consolidatePool(privateKeys, outputAddress, changeAddress)

setInterval(pendingUserAddresses, 10000)

generateCapitalOneAddress = () ->
    privateKey = bitcore.PrivateKey()
    publicKey = privateKey.toPublicKey()

    privateKeyString = privateKey.toWIF()
    # TODO: Store privateKeyString in database here.

    publicKeyString = publicKey.toString()
    # TODO: Store publicKeyString in database here.

    address = publicKey.toAddress()

    return address.toString()


