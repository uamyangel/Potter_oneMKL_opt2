#pragma once
#include "global.h"
#include <unordered_map>
#include <set>
#include <atomic>

#define NODE_CAPACITY 1
// class RouteNode;
// 注意：移除了 alignas(64) 因为会导致内存占用增加33%，缓存利用率下降
// 保留成员变量重排（热数据在前）以提高缓存命中率
class RouteNode
{
public:
	// RouteNode(){}
	RouteNode(obj_idx id_, short beginTileXCoordinate_, short beginTileYCoordinate_, short endTileXCoordinate_, short endTileYCoordinate_, float baseCost_, short length_, NodeType type_, bool isNodePinBounce_) :
		occupancy(0),
		id(id_),
		beginTileXCoordinate(beginTileXCoordinate_),
		beginTileYCoordinate(beginTileYCoordinate_),
		endTileXCoordinate(endTileXCoordinate_),
		endTileYCoordinate(endTileYCoordinate_),
		baseCost(baseCost_),
		length(length_),
		type(type_),
		isNodePinBounce(isNodePinBounce_),
		inlineSize(0) {
		// SVO: No need to reserve - using inline storage for first 8 children
	}
	RouteNode() : occupancy(0), inlineSize(0) {
		// SVO: No need to reserve - using inline storage for first 8 children
	}
	RouteNode(const RouteNode& that) : occupancy(0), inlineSize(0) {
		// Copy constructor: caller needs to explicitly copy children if needed
	};
	obj_idx getId() const {return id;}
	short getCapacity() const {return NODE_CAPACITY;}
	short getEndTileXCoordinate() const {return endTileXCoordinate;}
	short getEndTileYCoordinate() const {return endTileYCoordinate;}
	short getBeginTileXCoordinate() const {return beginTileXCoordinate;}
	short getBeginTileYCoordinate() const {return beginTileYCoordinate;}
	short getLength() const {return length;}
	bool getIsAccesibleWire() const {return isAccessibleWire;}
	float getBaseCost() const {return baseCost;}
	NodeType getNodeType() const {return type;}
	bool getIsNodePinBounce() const {return isNodePinBounce;}

	// 优化：Small Vector Optimization - 内联存储前8个子节点
	std::vector<RouteNode*> getChildren() const {
		std::vector<RouteNode*> result;
		if (inlineSize > 0) {
			result.insert(result.end(), inlineChildren, inlineChildren + inlineSize);
		}
		if (!overflowChildren.empty()) {
			result.insert(result.end(), overflowChildren.begin(), overflowChildren.end());
		}
		return result;
	}

	// 仅用于遍历，返回内联数组或overflow vector
	const RouteNode** getInlineChildrenPtr() const { return (const RouteNode**)inlineChildren; }
	uint8_t getInlineSize() const { return inlineSize; }
	const std::vector<RouteNode*>& getOverflowChildren() const { return overflowChildren; }

	int getChildrenSize() const {return inlineSize + overflowChildren.size();}

	float getPresentCongestionCost() const {return presentCongestionCost;}
	float getHistoricalCongestionCost() const {return historicalCongestionCost;}

	void setId(obj_idx v) {id = v;}
	void setEndTileXCoordinate(short v) {endTileXCoordinate = v;}
	void setEndTileYCoordinate(short v) {endTileYCoordinate = v;}
	void setBeginTileXCoordinate(short v) {beginTileXCoordinate = v;}
	void setBeginTileYCoordinate(short v) {beginTileYCoordinate = v;}
	void setLength(short v) {length = v;}
	void setIsAccesibleWire(bool v) {isAccessibleWire = v;}
	void setBaseCost(float v) {baseCost = v;}
	void setIsNodePinBounce(bool v) {isNodePinBounce = v;}

	void setChildren(std::vector<RouteNode*> cs) {
		inlineSize = 0;
		overflowChildren.clear();
		for (auto* child : cs) {
			addChildren(child);
		}
	}

	void clearChildren() {
		inlineSize = 0;
		overflowChildren.clear();
	}

	// 优化：Small Vector Optimization - 优先使用内联存储
	void addChildren(RouteNode* c) {
		if (inlineSize < INLINE_CAPACITY) {
			inlineChildren[inlineSize++] = c;
		} else {
			overflowChildren.push_back(c);
		}
	}

	void setNodeType(NodeType t) {type = t;}

	void setPresentCongestionCost(float cost) {presentCongestionCost = cost;}
	void updatePresentCongestionCost(float pres_fac) {
        int occ = getOccupancy();
        if (occ < NODE_CAPACITY)
            setPresentCongestionCost(1);
        else 
            setPresentCongestionCost(1 + (occ - NODE_CAPACITY + 1) * pres_fac);
    }
	void setHistoricalCongestionCost(float cost) {historicalCongestionCost = cost;}

	// methods for usersConnectionCounts
	// Optimized: Use relaxed memory order for high-frequency reads
	// The routing algorithm is heuristic and tolerates minor inconsistencies
	int getOccupancy() const {
		return occupancy.load(std::memory_order_relaxed);
	}

	bool isOverUsed () const {return NODE_CAPACITY < getOccupancy();}

	// Relaxed increments: still atomic but much faster
	void incrementOccupancy() {
		occupancy.fetch_add(1, std::memory_order_relaxed);
	}
	void decrementOccupancy() {
		occupancy.fetch_sub(1, std::memory_order_relaxed);
	}

	void setNeedUpdateBatchStamp(int batchStamp) {needUpdateBatchStamp = batchStamp;}
	int getNeedUpdateBatchStamp() const {return needUpdateBatchStamp;}

private:
	// Small Vector Optimization: 内联存储前N个子节点
	static constexpr uint8_t INLINE_CAPACITY = 8;

	// 优化：热数据区（频繁访问的字段放在前面，提高缓存命中率）
	std::atomic<int> occupancy;              // 最频繁访问：每次路由都读写
	int needUpdateBatchStamp = -1;           // 频繁访问：批次更新检查
	float presentCongestionCost = 1;         // 频繁访问：成本计算
	float historicalCongestionCost = 1;      // 频繁访问：成本计算

	// 冷数据区（初始化后很少改变的字段）
	obj_idx id;
	short endTileXCoordinate;
	short endTileYCoordinate;
	short beginTileXCoordinate;
	short beginTileYCoordinate;
	short length = 1;
	float baseCost;
	NodeType type;
	bool isAccessibleWire;
	bool isNodePinBounce;

	// Small Vector Optimization: 内联数组 + overflow vector
	RouteNode* inlineChildren[INLINE_CAPACITY];
	uint8_t inlineSize = 0;
	std::vector<RouteNode*> overflowChildren;

	friend class boost::serialization::access;
	template<class Archive>
    void serialize(Archive & ar, const unsigned int version)
    {
        ar & id;
		// short capacity = 1;
		ar & endTileXCoordinate;
		ar & endTileYCoordinate;
		ar & beginTileXCoordinate;
		ar & beginTileYCoordinate;
		ar & length;
		ar & isAccessibleWire;
		ar & baseCost;
		ar & type;
		ar & isNodePinBounce;

		// ar & upStreamPathCost;
		// ar & lowerBoundTotalPathCost;
    }
};

class NodeInfo {
private:
	int occChange;
	int occChangeBatchStamp; // iter * numBatches + batchId
public:
    RouteNode* prev;
    double cost;
    double partialCost;
	int isVisited;
    int isTarget;

	NodeInfo(): prev(nullptr), cost(0), partialCost(0), isVisited(-1), isTarget(-1), occChange(0), occChangeBatchStamp(-1) {}

	// Optimized: Fast reset without full reconstruction
	inline void reset() {
		prev = nullptr;
		cost = 0;
		partialCost = 0;
		isVisited = -1;
		isTarget = -1;
		// Note: occChange and occChangeBatchStamp are managed separately
	}

	void erase() {
		reset();  // Use the optimized reset method
	}

	void write(RouteNode* prev_, double cost_, double partialCost_, int isVisited_, int isTarget_) {
		prev = prev_; cost = cost_; partialCost = partialCost_; isVisited = isVisited_; isTarget = isTarget_;
	}

	void write(NodeInfo* ninfo) { write(ninfo->prev, ninfo->cost, ninfo->partialCost, ninfo->isVisited, ninfo->isTarget); }

	void write(NodeInfo& ninfo) { write(ninfo.prev, ninfo.cost, ninfo.partialCost, ninfo.isVisited, ninfo.isTarget); }

	int getOccChange(int batchStamp) {
		if (batchStamp != occChangeBatchStamp)
			// batchStamp > occChangeBatchStamp, invalid record
			return 0;

		return occChange;
	}

	void incOccChange(int batchStamp) {
		if (batchStamp != occChangeBatchStamp) {
			// batchStamp > occChangeBatchStamp, invalid record
			occChangeBatchStamp = batchStamp;
			occChange = 1;
		} else {
			occChange ++;
		}
	}

	void decOccChange(int batchStamp) {
		if (batchStamp != occChangeBatchStamp) {
			// batchStamp > occChangeBatchStamp, invalid record
			occChangeBatchStamp = batchStamp;
			occChange = -1;
		} else {
			occChange --;
		}
	}
};