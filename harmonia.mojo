from algorithm import vectorize
from math import round
from memory.unsafe import DTypePointer
from sys.info import simdwidthof


alias keyType = DType.int32
alias nelts = simdwidthof[keyType]()

struct Harmonia:
    var key_region: DTypePointer[keyType]
    var child_region: DTypePointer[keyType]
    var fanout: Int

    fn __init__(inout self, fanout: Int):
        self.key_region = DTypePointer[keyType].alloc((fanout - 1) * 4)
        self.child_region = DTypePointer[keyType].alloc(1)
        self.fanout = fanout

        # for testing only
        self.key_region.store(0, 100)
        self.key_region.store(1, 200)

        self.key_region.store(2, 30)
        self.key_region.store(3, 50)

        self.key_region.store(4, 120)
        self.key_region.store(5, 150)

        self.key_region.store(6, 250)
        self.key_region.store(7, 300)

        self.child_region.store(0, 1)
    
    @always_inline
    fn query(self, key: Int) -> Int:
        var node_idx: Int = 0
        var k: Int = 0
        var not_found = True
        while not_found:
            let keys = self.key_region.simd_load[nelts](node_idx)
            print(keys)
            #let simd_key = SIMD[keyType, nelts](key)
            #print(simd_key)
            #let res = keys >= simd_key
            #print(res)
            k = self.fanout
            for i in range(self.fanout - 1):
                if key < keys[i].to_int():
                    k = i + 1
                    break

            let child_idx = (self.child_region.load(node_idx) + k - 1) * (self.fanout - 1)

            if child_idx >= (self.fanout - 1) * 4:
                not_found = False
            else:
                node_idx = child_idx.to_int()

            print("child_idx", child_idx)
            print("k", k)

            
        return node_idx
    
    # @always_inline
    # fn __getitem__(self, y: Int, x: Int) -> Float32:
    #     return self.load[1](y, x)

    # @always_inline
    # fn load[nelts:Int](self, y: Int, x: Int) -> SIMD[DType.float32, nelts]:
    #     return self.data.simd_load[nelts](y * self.cols + x)

    # @always_inline
    # fn __setitem__(self, y: Int, x: Int, val: Float32):
    #     return self.store[1](y, x, val)

    # @always_inline
    # fn store[nelts:Int](self, y: Int, x: Int, val: SIMD[DType.float32, nelts]):
    #     self.data.simd_store[nelts](y * self.cols + x, val)


fn main():
    print("nelts", nelts)
    var h = Harmonia(3)
    print(h.query(260))