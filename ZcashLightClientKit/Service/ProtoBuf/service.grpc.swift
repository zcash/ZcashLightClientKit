//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import GRPC
import NIO
import NIOHTTP1
import SwiftProtobuf


/// Usage: instantiate CompactTxStreamerClient, then call methods of this protocol to make API calls.
internal protocol CompactTxStreamerClientProtocol {
  func getLatestBlock(_ request: ChainSpec, callOptions: CallOptions?) -> UnaryCall<ChainSpec, BlockID>
  func getBlock(_ request: BlockID, callOptions: CallOptions?) -> UnaryCall<BlockID, CompactBlock>
  func getBlockRange(_ request: BlockRange, callOptions: CallOptions?, handler: @escaping (CompactBlock) -> Void) -> ServerStreamingCall<BlockRange, CompactBlock>
  func getTransaction(_ request: TxFilter, callOptions: CallOptions?) -> UnaryCall<TxFilter, RawTransaction>
  func sendTransaction(_ request: RawTransaction, callOptions: CallOptions?) -> UnaryCall<RawTransaction, SendResponse>
  func getAddressTxids(_ request: TransparentAddressBlockFilter, callOptions: CallOptions?, handler: @escaping (RawTransaction) -> Void) -> ServerStreamingCall<TransparentAddressBlockFilter, RawTransaction>
  func getLightdInfo(_ request: Empty, callOptions: CallOptions?) -> UnaryCall<Empty, LightdInfo>
  func ping(_ request: Duration, callOptions: CallOptions?) -> UnaryCall<Duration, PingResponse>
}

internal final class CompactTxStreamerClient: GRPCClient, CompactTxStreamerClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the cash.z.wallet.sdk.rpc.CompactTxStreamer service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions()) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
  }

  /// Return the height of the tip of the best chain
  ///
  /// - Parameters:
  ///   - request: Request to send to GetLatestBlock.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getLatestBlock(_ request: ChainSpec, callOptions: CallOptions? = nil) -> UnaryCall<ChainSpec, BlockID> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetLatestBlock",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Return the compact block corresponding to the given block identifier
  ///
  /// - Parameters:
  ///   - request: Request to send to GetBlock.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getBlock(_ request: BlockID, callOptions: CallOptions? = nil) -> UnaryCall<BlockID, CompactBlock> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetBlock",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Return a list of consecutive compact blocks
  ///
  /// - Parameters:
  ///   - request: Request to send to GetBlockRange.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getBlockRange(_ request: BlockRange, callOptions: CallOptions? = nil, handler: @escaping (CompactBlock) -> Void) -> ServerStreamingCall<BlockRange, CompactBlock> {
    return self.makeServerStreamingCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetBlockRange",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

  /// Return the requested full (not compact) transaction (as from zcashd)
  ///
  /// - Parameters:
  ///   - request: Request to send to GetTransaction.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getTransaction(_ request: TxFilter, callOptions: CallOptions? = nil) -> UnaryCall<TxFilter, RawTransaction> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetTransaction",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Submit the given transaction to the zcash network
  ///
  /// - Parameters:
  ///   - request: Request to send to SendTransaction.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func sendTransaction(_ request: RawTransaction, callOptions: CallOptions? = nil) -> UnaryCall<RawTransaction, SendResponse> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/SendTransaction",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Return the txids corresponding to the given t-address within the given block range
  ///
  /// - Parameters:
  ///   - request: Request to send to GetAddressTxids.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  ///   - handler: A closure called when each response is received from the server.
  /// - Returns: A `ServerStreamingCall` with futures for the metadata and status.
  internal func getAddressTxids(_ request: TransparentAddressBlockFilter, callOptions: CallOptions? = nil, handler: @escaping (RawTransaction) -> Void) -> ServerStreamingCall<TransparentAddressBlockFilter, RawTransaction> {
    return self.makeServerStreamingCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetAddressTxids",
                                        request: request,
                                        callOptions: callOptions ?? self.defaultCallOptions,
                                        handler: handler)
  }

  /// Return information about this lightwalletd instance and the blockchain
  ///
  /// - Parameters:
  ///   - request: Request to send to GetLightdInfo.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getLightdInfo(_ request: Empty, callOptions: CallOptions? = nil) -> UnaryCall<Empty, LightdInfo> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/GetLightdInfo",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Testing-only
  ///
  /// - Parameters:
  ///   - request: Request to send to Ping.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func ping(_ request: Duration, callOptions: CallOptions? = nil) -> UnaryCall<Duration, PingResponse> {
    return self.makeUnaryCall(path: "/cash.z.wallet.sdk.rpc.CompactTxStreamer/Ping",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

}


// Provides conformance to `GRPCPayload` for request and response messages
extension ChainSpec: GRPCProtobufPayload {}
extension BlockID: GRPCProtobufPayload {}
extension CompactBlock: GRPCProtobufPayload {}
extension BlockRange: GRPCProtobufPayload {}
extension TxFilter: GRPCProtobufPayload {}
extension SendResponse: GRPCProtobufPayload {}
extension TransparentAddressBlockFilter: GRPCProtobufPayload {}
extension LightdInfo: GRPCProtobufPayload {}
extension Duration: GRPCProtobufPayload {}
extension PingResponse: GRPCProtobufPayload {}
extension RawTransaction: GRPCProtobufPayload {}
extension Empty: GRPCProtobufPayload {}
