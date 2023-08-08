enum ServerConvertState {
  waiting, // 等待中
  converting, // 轉換中
  notFound, // 未找到
  finished, // 完成
  fail, // 失敗
}

// 將字串映射至對應的 ServerConvertState 列舉值
const serverConvertStateMap = <String?, ServerConvertState>{
  "Waiting": ServerConvertState.waiting,
  "Converting": ServerConvertState.converting,
  "NotFound": ServerConvertState.notFound,
  "Finished": ServerConvertState.finished,
  "Fail": ServerConvertState.fail,
};

// 對 String? 的擴充，提供轉換為 ServerConvertState 的功能
extension ServerConvertStateStringExtensions on String? {
  ServerConvertState toServerConvertState() {
    return serverConvertStateMap[this] ?? ServerConvertState.converting;
  }
}

// 轉換資訊類別，包含 UUID、轉換類型、狀態、畫布版本等資訊
class ConversionInfo {
  String uuid;
  String type;
  ServerConvertState status;
  bool? canvasVersion;
  Progress? progress;

  ConversionInfo({
    required this.uuid,
    required this.type,
    required this.status,
    this.canvasVersion,
    this.progress,
  });

  // 從 JSON 資料建立 ConversionInfo 物件
  ConversionInfo.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        type = json['type'],
        status = (json['status'] as String?).toServerConvertState(),
        canvasVersion = json['canvasVersion'],
        progress = json['progress'] != null
            ? Progress.fromJson(json['progress'])
            : null;

  // 將 ConversionInfo 物件轉換為 JSON 資料
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['type'] = type;
    data['status'] = status;
    data['canvasVersion'] = canvasVersion;
    if (progress != null) {
      data['progress'] = progress!.toJson();
    }
    return data;
  }
}

// 進度資訊類別，包含轉換進度的相關資訊
class Progress {
  int? totalPageSize;
  int? convertedPageSize;
  int? convertedPercentage;
  List<ConvertedFileList>? convertedFileList;
  String? currentStep;
  String? prefix;

  Progress({
    this.totalPageSize,
    this.convertedPageSize,
    this.convertedPercentage,
    this.convertedFileList,
    this.currentStep,
    this.prefix,
  });

  // 從 JSON 資料建立 Progress 物件
  Progress.fromJson(Map<String, dynamic> json) {
    totalPageSize = json['totalPageSize'];
    convertedPageSize = json['convertedPageSize'];
    convertedPercentage = json['convertedPercentage'];
    if (json['convertedFileList'] != null) {
      convertedFileList = (json['convertedFileList'] as Iterable).map((v) {
        return ConvertedFileList.fromJson(v);
      }).toList();
    }
    currentStep = json['currentStep'];
    prefix = json['prefix'];
  }

  // 將 Progress 物件轉換為 JSON 資料
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalPageSize'] = totalPageSize;
    data['convertedPageSize'] = convertedPageSize;
    data['convertedPercentage'] = convertedPercentage;
    if (convertedFileList != null) {
      data['convertedFileList'] =
          convertedFileList!.map((v) => v.toJson()).toList();
    }
    data['currentStep'] = currentStep;
    data['prefix'] = prefix;
    return data;
  }
}

// 轉換後檔案清單類別，包含轉換後的檔案資訊
class ConvertedFileList {
  int? width;
  int? height;
  String? conversionFileUrl;
  String? preview;

  ConvertedFileList({
    this.width,
    this.height,
    this.conversionFileUrl,
    this.preview,
  });

  // 從 JSON 資料建立 ConvertedFileList 物件
  ConvertedFileList.fromJson(Map<String, dynamic> json) {
    width = json['width'];
    height = json['height'];
    conversionFileUrl = json['conversionFileUrl'];
    preview = json['preview'];
  }

  // 將 ConvertedFileList 物件轉換為 JSON 資料
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['width'] = width;
    data['height'] = height;
    data['preview'] = preview;
    data['conversionFileUrl'] = conversionFileUrl;
    return data;
  }
}
